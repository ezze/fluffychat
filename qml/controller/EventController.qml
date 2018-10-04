import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0


/* =============================== EVENT CONTROLLER ===============================

The event controller is responsible for handling all events and stay connected
with the matrix homeserver via a long polling http request

To try fluffychat with clickable --desktop you need to remove the line:
import Ubuntu.Connectivity 1.0
and the Connections{ } to Connectivity down there
*/
Item {

    property var statusMap: ["Offline", "Connecting", "Online"]

    Connections {
        target: Connectivity
        // full status can be retrieved from the base C++ class
        // status property
        onOnlineChanged: if ( Connectivity.online ) restartSync ()
    }

    /* The newEvent signal is the most importent signal in this concept. Every time
    * the app receives a new synchronization, this event is called for every signal
    * to update the GUI. For example, for a new message, it is called:
    * onNewEvent( "m.room.message", "!chat_id:server.com", "timeline", {sender: "@bob:server.com", body: "Hello world"} )
    */
    signal newEvent ( var type, var chat_id, var eventType, var eventContent )
    /* Outside of the events there are updates for the global chat states which
    * are handled by this signal:
    */
    signal newChatUpdate ( var chat_id, var membership, var notification_count, var highlight_count, var limitedTimeline )

    property var syncRequest: null
    property var initialized: false
    property var abortSync: false

    function init () {
        if ( !Connectivity.online ) return

        // Set the pusher if it is not set
        if ( settings.pushToken !== pushtoken ) {
            console.log("👷 Trying to set pusher…")
            pushclient.setPusher ( true, function () {
                settings.pushToken = pushtoken
                console.log("😊 Pusher is set!")
            } )
        }

        // Start synchronizing
        initialized = true
        if ( settings.since ) {
            waitForSync ()
            return sync ( 1 )
        }
        loadingScreen.visible = true
        storage.transaction ( "INSERT OR IGNORE INTO Users VALUES ( '" +
        matrix.matrixid + "', '" + usernames.transformFromId(matrix.matrixid) + "', '' )" )

        matrix.get( "/client/r0/sync", {}, function ( response ) {
            if ( waitingForSync ) progressBarRequests--
            handleEvents ( response )
            matrix.onlineStatus = true

            matrix.get( "/client/r0/sync", { filter: "{\"room\":{\"include_leave\":true,\"state\":{\"not_types\":[\"m.room.member\"]}}}" }, handleEvents )

            if ( !abortSync ) sync ()
        }, init, null, longPollingTimeout )
    }


    function sync ( timeout ) {

        if ( settings.token === null || settings.token === undefined || abortSync ) return

        var data = { "since": settings.since }

        if ( !timeout ) data.timeout = longPollingTimeout

        syncRequest = matrix.get ("/client/r0/sync", data, function ( response ) {

            if ( waitingForSync ) progressBarRequests--
            waitingForSync = false
            if ( settings.token ) {
                matrix.onlineStatus = true
                handleEvents ( response )
                sync ()
            }
        }, function ( error ) {
            if ( !abortSync && settings.token !== undefined ) {
                matrix.onlineStatus = false
                if ( error.errcode === "M_INVALID" ) {
                    mainStack.clear ()
                    mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
                }
                else {
                    if ( Connectivity && Connectivity.online ) restartSync ()
                    else console.error ( i18n.tr("You are offline 😕") )
                }
            }
        } );
    }


    function restartSync () {
        if ( !initialized ) return init()
        if ( syncRequest === null ) return
        if ( syncRequest ) {
            abortSync = true
            syncRequest.abort ()
            abortSync = false
        }
        sync ( true )
    }


    function waitForSync () {
        if ( waitingForSync ) return
        waitingForSync = true
        progressBarRequests++
    }


    function stopWaitForSync () {
        if ( !waitingForSync ) return
        waitingForSync = false
        progressBarRequests--
    }

    property var transaction


    // This function starts handling the events, saving new data in the storage,
    // deleting data, updating data and call signals
    function handleEvents ( response ) {

        //console.log( "===== NEW SYNC:", JSON.stringify( response ) )
        var changed = false
        var timecount = new Date().getTime()
        try {
            storage.db.transaction(
                function(tx) {
                    transaction = tx
                    handleRooms ( response.rooms.join, "join" )
                    handleRooms ( response.rooms.leave, "leave" )
                    handleRooms ( response.rooms.invite, "invite" )

                    settings.since = response.next_batch
                    loadingScreen.visible = false
                    //console.log("===> RECEIVED RESPONSE! SYNCHRONIZATION performance: ", new Date().getTime() - timecount )
                }
            )
        }
        catch ( e ) {
            toast.show ( i18n.tr("😰 A critical error has occurred! Sorry, the connection to the server has ended! Please report this bug on: https://github.com/ChristianPauly/fluffychat/issues/new") )
            console.log ( e )
            abortSync = true
            syncRequest.abort ()
            return
        }
    }


    // Handling the synchronization events starts with the rooms, which means
    // that the informations should be saved in the database
    function handleRooms ( rooms, membership ) {
        for ( var id in rooms ) {
            var room = rooms[id]

            // If the membership of the user is "leave" then the chat and all
            // events and user-memberships should be removed.
            // If not, it is "join" or "invite" and everything should be saved

            var highlight_count = (room.unread_notifications && room.unread_notifications.highlight_count || 0)
            var notification_count = (room.unread_notifications && room.unread_notifications.notification_count || 0)
            var limitedTimeline = (room.timeline ? (room.timeline.limited ? 1 : 0) : 0)

            // Call the newChatUpdate signal for updating the GUI:



            // Insert the chat into the database if not exists
            var insertResult = transaction.executeSql ("INSERT OR IGNORE INTO Chats " +
            "VALUES('" + id + "', '" + membership + "', '', 0, 0, 0, '', '', '', '', '', '', '', '', '', 0, 50, 50, 0, 50, 50, 0, 50, 100, 50, 50, 50, 100) ")

            // Update the notification counts and the limited timeline boolean
            var updateResult = transaction.executeSql ( "UPDATE Chats SET " +
            " highlight_count=" + highlight_count +
            ", notification_count=" + notification_count +
            ", membership='" + membership +
            "', limitedTimeline=" + limitedTimeline +
            " WHERE id='" + id + "' AND ( " +
            " highlight_count!=" + highlight_count +
            " OR notification_count!=" + notification_count +
            " OR membership!='" + membership +
            "' OR limitedTimeline!=" + limitedTimeline +
            ") ")

            // Update the GUI
            if ( updateResult.rowsAffected > 0 || insertResult.rowsAffected > 0 ) {
                newChatUpdate ( id, membership, notification_count, highlight_count, limitedTimeline )
            }

            // Handle now all room events and save them in the database
            if ( room.state ) handleRoomEvents ( id, room.state.events, "state", room )
            if ( room.invite_state ) handleRoomEvents ( id, room.invite_state.events, "invite_state", room )
            if ( room.timeline ) {
                // Is the timeline limited? Then all previous messages should be
                // removed from the database!
                if ( room.timeline.limited ) {
                    transaction.executeSql ("DELETE FROM Events WHERE chat_id='" + id + "'")
                    transaction.executeSql ("UPDATE Chats SET prev_batch='" + room.timeline.prev_batch + "' WHERE id='" + id + "'")
                }
                handleRoomEvents ( id, room.timeline.events, "timeline", room )
            }
            if ( room.ephemeral ) handleEphemeral ( id, room.ephemeral.events )
        }
    }


    // Handle ephemerals (message receipts)
    function handleEphemeral ( id, events ) {
        for ( var i = 0; i < events.length; i++ ) {
            if ( events[i].type === "m.receipt" ) {
                for ( var e in events[i].content ) {
                    for ( var user in events[i].content[e]["m.read"]) {
                        if ( user === matrix.matrixid ) continue
                        var timestamp = events[i].content[e]["m.read"][user].ts

                        // Call the newEvent signal for updating the GUI
                        newEvent ( events[i].type, id, "ephemeral", { ts: timestamp, user: user } )

                        // Mark all previous received messages as seen
                        transaction.executeSql ( "UPDATE Events SET status=3 WHERE origin_server_ts<=" + timestamp +
                        " AND chat_id='" + id + "' AND status=2")

                    }
                }
            }
            if ( events[ i ].type === "m.typing" ) {
                var user_ids = events[ i ].content.user_ids
                // If the user is typing, remove his id from the list of typing users
                var ownTyping = user_ids.indexOf( matrix.matrixid )
                if ( ownTyping !== -1 ) user_ids.splice( ownTyping, 1 )
                // Call the signal
                newEvent ( events[ i ].type, id, "ephemeral", user_ids )
            }
        }
    }


    // Events are all changes in a room
    function handleRoomEvents ( roomid, events, type ) {

        // We go through the events array
        for ( var i = 0; i < events.length; i++ ) {
            var event = events[i]

            // messages from the timeline will be saved, for display in the chat.
            // Only this events will call the notification signal or change the
            // current displayed chat!
            if ( type === "timeline" || type === "history" ) {
                var status = type === "timeline" ? msg_status.RECEIVED : msg_status.HISTORY

                // Format the text for the app
                var tempText = event.content.body || null
                if ( tempText !== null ) {
                    tempText = tempText.split("\n").join("<br>")
                    var urlRegex = /(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])/igm
                    tempText = tempText.replace(urlRegex, function(url) {
                        var link = url
                        if ( url.indexOf ( "http" ) === -1 ) link = "http://" + url
                        return '<a href="%1">%2</a>'.arg(link).arg(url)
                    })
                }
                event.content_body = tempText
                transaction.executeSql ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [ event.event_id,
                roomid,
                event.origin_server_ts,
                event.sender,
                event.content_body,
                event.content.msgtype || null,
                event.type,
                JSON.stringify(event.content),
                status ])
            }


            // If the message contains an image, save it to media
            if ( event.type === "sticker" ) {
                transaction.executeSql( "INSERT OR IGNORE INTO Media VALUES(?, ?, ?, ?)", [
                (event.info && event.info.mimetype) ? event.info.mimetype : "",
                event.content.url,
                event.content.body || "image",
                (event.info && event.info.thumbnail_url) ? event.info.thumbnail_url : ""
                ])
            }


            // If this timeline only contain events from the history, from the past,
            // then all other changes to the room are old and should not be saved.
            if ( type === "history" ) continue

            // This event means, that the name of a room has been changed, so
            // it has to be changed in the database.
            if ( event.type === "m.room.name" ) {
                transaction.executeSql( "UPDATE Chats SET topic=? WHERE id=?",
                [ event.content.name,
                roomid ])
                // If the affected room is the currently used room, then the
                // name has to be updated in the GUI:
                if ( activeChat === roomid ) {
                    roomnames.getById ( roomid, function ( displayname ) {
                        activeChatDisplayName = displayname
                    })
                }
            }


            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.topic" ) {
                transaction.executeSql( "UPDATE Chats SET description=? WHERE id=?",
                [ event.content.topic || "",
                roomid ])
            }


            // This event means, that the canonical alias of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.canonical_alias" ) {
                transaction.executeSql( "UPDATE Chats SET canonical_alias=? WHERE id=?",
                [ event.content.alias || "",
                roomid ])
            }


            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.history_visibility" ) {
                transaction.executeSql( "UPDATE Chats SET history_visibility=? WHERE id=?",
                [ event.content.history_visibility,
                roomid ])
            }


            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.redaction" ) {
                transaction.executeSql( "DELETE FROM Events WHERE id=?",
                [ event.redacts ])
            }


            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.guest_access" ) {
                transaction.executeSql( "UPDATE Chats SET guest_access=? WHERE id=?",
                [ event.content.guest_access,
                roomid ])
            }


            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.join_rules" ) {
                transaction.executeSql( "UPDATE Chats SET join_rules=? WHERE id=?",
                [ event.content.join_rule,
                roomid ])
            }


            // This event means, that the avatar of a room has been changed, so
            // it has to be changed in the database
            else if ( event.type === "m.room.avatar" ) {
                transaction.executeSql( "UPDATE Chats SET avatar_url=? WHERE id=?",
                [ event.content.url,
                roomid ])
            }


            // This event means, that the aliases of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.aliases" ) {
                transaction.executeSql( "DELETE FROM Addresses WHERE chat_id='" + roomid + "'")
                for ( var alias = 0; alias < event.content.aliases.length; alias++ ) {
                    transaction.executeSql( "INSERT INTO Addresses VALUES(?,?)",
                    [ roomid, event.content.aliases[alias] ] )
                }
            }


            // This event means, that someone joined the room, has left the room
            // or has changed his nickname
            else if ( event.type === "m.room.member" ) {

                if ( event.content.membership !== "leave" && event.content.membership !== "ban" ) transaction.executeSql( "INSERT OR REPLACE INTO Users VALUES(?, ?, ?)",
                [ event.state_key,
                event.content.displayname || usernames.transformFromId(event.state_key),
                event.content.avatar_url || "" ])

                transaction.executeSql( "INSERT OR REPLACE INTO Memberships VALUES('" + roomid + "', '" + event.state_key + "', ?, " +
                "COALESCE(" +
                "(SELECT power_level FROM Memberships WHERE chat_id='" + roomid + "' AND matrix_id='" + event.state_key + "'), " +
                "(SELECT power_user_default FROM Chats WHERE id='" + roomid + "')" +
                "))",
                [ event.content.membership ])
            }

            // This event changes the permissions of the users and the power levels
            else if ( event.type === "m.room.power_levels" ) {
                var query = "UPDATE Chats SET "
                if ( event.content.ban ) query += ", power_ban=" + event.content.ban
                if ( event.content.events_default ) query += ", power_events_default=" + event.content.events_default
                if ( event.content.state_default ) query += ", power_state_default=" + event.content.state_default
                if ( event.content.redact ) query += ", power_redact=" + event.content.redact
                if ( event.content.invite ) query += ", power_invite=" + event.content.invite
                if ( event.content.kick ) query += ", power_kick=" + event.content.kick
                if ( event.content.user_default ) query += ", power_user_default=" + event.content.user_default
                if ( event.content.events ) {
                    if ( event.content.events["m.room.avatar"] ) query += ", power_event_avatar=" + event.content.events["m.room.avatar"]
                    if ( event.content.events["m.room.history_visibility"] ) query += ", power_event_history_visibility=" + event.content.events["m.room.history_visibility"]
                    if ( event.content.events["m.room.canonical_alias"] ) query += ", power_event_canonical_alias=" + event.content.events["m.room.canonical_alias"]
                    if ( event.content.events["m.room.aliases"] ) query += ", power_event_aliases=" + event.content.events["m.room.aliases"]
                    if ( event.content.events["m.room.name"] ) query += ", power_event_name=" + event.content.events["m.room.name"]
                    if ( event.content.events["m.room.power_levels"] ) query += ", power_event_power_levels=" + event.content.events["m.room.power_levels"]
                }
                if ( query !== "UPDATE Chats SET ") {
                    query = query.replace(",","")
                    transaction.executeSql( query + " WHERE id=?",[ roomid ])
                }

                // Set the users power levels:
                if ( event.content.users ) {
                    for ( var user in event.content.users ) {
                        transaction.executeSql( "UPDATE Memberships SET power_level=? WHERE matrix_id=? AND chat_id=?",
                        [ event.content.users[user],
                        user,
                        roomid ])
                    }
                }
            }

            // Call the newEvent signal for updating the GUI
            newEvent ( event.type, roomid, type, event )
        }
    }
}
