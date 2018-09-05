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

    signal chatListUpdated ( var response )
    signal chatTimelineEvent ( var response )

    property var syncRequest: null
    property var initialized: false
    property var abortSync: false

    function init () {

        // Set the pusher if it is not set
        if ( !settings.pusherIsSet ) {
            console.log("👷 Trying to set pusher ...")
            pushclient.setPusher ( true, function () {
                settings.pusherIsSet = true
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
        //toast.show ( i18n.tr("Synchronizing \n This can take a few minutes ...") )
        matrix.get ("/client/r0/sync", null,function ( response ) {
            if ( waitingForSync ) progressBarRequests--
            matrix.onlineStatus = true
            handleEvents ( response )
            sync ()
        }, init, null, longPollingTimeout )
    }

    function sync ( timeout ) {

        if ( settings.token === null || settings.token === undefined ) return

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
                    else toast.show ( i18n.tr("You are offline 😕") )
                    console.log ( "Synchronization error! Try to restart ..." )
                }
            }
        } );
    }


    function restartSync () {
        if ( syncRequest === null ) return
        console.log("resync")
        if ( syncRequest ) {
            console.log( "Stopping latest sync" )
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
                    triggerSignals ( response )
                    loadingScreen.visible = false
                    //console.log("===> RECEIVED RESPONSE! SYNCHRONIZATION performance: ", new Date().getTime() - timecount )
                }
            )
        }
        catch ( e ) {
            toast.show ( "CRITICAL ERROR:", e )
            console.log ( e )
        }
    }


    function triggerSignals ( response ) {
        var activeRoom = response.rooms.join[activeChat]

        chatListUpdated ( response )

        // Is there a new chat timeline event in the active room?
        if ( activeRoom !== undefined ) chatTimelineEvent ( activeRoom )
    }


    // Handling the synchronization events starts with the rooms, which means
    // that the informations should be saved in the database
    function handleRooms ( rooms, membership ) {
        for ( var id in rooms ) {
            var room = rooms[id]

            // If the membership of the user is "leave" then the chat and all
            // events and user-memberships should be removed.
            // If not, it is "join" or "invite" and everything should be saved
            if ( membership !== "leave" ) {

                // Insert the chat into the database if not exists
                transaction.executeSql ("INSERT OR IGNORE INTO Chats " +
                "VALUES('" + id + "', '" + membership + "', '', 0, 0, 0, '', '', '', 0) ")
                // Update the notification counts and the limited timeline boolean
                transaction.executeSql ( "UPDATE Chats SET " +
                " highlight_count=" +
                (room.unread_notifications && room.unread_notifications.highlight_count || 0) +
                ", notification_count=" +
                (room.unread_notifications && room.unread_notifications.notification_count || 0) +
                ", limitedTimeline=" +
                (room.timeline ? (room.timeline.limited ? 1 : 0) : 0) +
                " WHERE id='" + id + "' ")

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
            else {
                transaction.executeSql ( "DELETE FROM Chats WHERE id='" + id + "'")
                transaction.executeSql ( "DELETE FROM Memberships WHERE chat_id='" + id + "'")
                transaction.executeSql ( "DELETE FROM Events WHERE chat_id='" + id + "'")
            }
        }
    }


    // Handle ephemerals (message receipts)
    function handleEphemeral ( id, events ) {
        for ( var i = 0; i < events.length; i++ ) {
            if ( events[i].type === "m.receipt" ) {
                for ( var e in events[i].content ) {
                    for ( var user in events[i].content[e]["m.read"]) {
                        var timestamp = events[i].content[e]["m.read"][user].ts
                        console.log(timestamp)
                        transaction.executeSql ( "UPDATE Events SET status=3 WHERE origin_server_ts<=" + timestamp +
                        " AND chat_id='" + id + "' AND status=2")
                    }
                }
            }
        }
    }


    // Events are all changes in a room
    function handleRoomEvents ( roomid, events, type, room ) {

        // We go through the events array
        for ( var i = 0; i < events.length; i++ ) {
            var event = events[i]

            // messages from the timeline will be saved, for display in the chat.
            // Only this events will call the notification signal or change the
            // current displayed chat!
            if ( type === "timeline" || type === "history" ) {
                transaction.executeSql ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [ event.event_id,
                roomid,
                event.origin_server_ts,
                event.sender,
                event.content.body || null,
                event.content.msgtype || null,
                event.type,
                JSON.stringify(event.content),
                msg_status.RECEIVED ])
            }

            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
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

            // This event means, that the avatar of a room has been changed, so
            // it has to be changed in the database
            else if ( event.type === "m.room.avatar" ) {
                transaction.executeSql( "UPDATE Chats SET avatar_url=? WHERE id=?",
                [ event.content.url,
                roomid ])
            }

            // This event means, that someone joined the room, has left the room
            // or has changed his nickname
            else if ( event.type === "m.room.member" ) {

                transaction.executeSql( "INSERT OR REPLACE INTO Users VALUES(?, ?, ?)",
                [ event.state_key,
                event.content.displayname,
                event.content.avatar_url ])

                transaction.executeSql( "INSERT OR REPLACE INTO Memberships VALUES('" + roomid + "', ?, ?)",
                [ event.state_key,
                event.content.membership ])

                if ( event.state_key === matrix.matrixid) {
                    settings.avatar_url = event.content.avatar_url
                    settings.displayname = event.content.displayname
                }
            }
        }
    }
}
