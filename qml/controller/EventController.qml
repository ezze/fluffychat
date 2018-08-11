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
    signal chatTypingEvent ( var roomid, var user_ids )

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
        toast.show ( i18n.tr("Synchronizing \n This can take a few minutes ...") )
        matrix.get ("/client/r0/sync", null,function ( response ) {
            if ( waitingForSync ) progressBarRequests--
            matrix.onlineStatus = true
            handleEvents ( response )
            sync ()
        }, null, null, longPollingTimeout )
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
                    chatListUpdated ( response )
                    triggerSignals ( response )
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

        // Is there a new chat timeline event in the active room?
        if ( activeRoom !== undefined && activeRoom.timeline.events.length > 0 ) chatTimelineEvent ( activeRoom.timeline.events )

        // Check the ephemerals for typing events
        for( var room in response.rooms.join ) {
            if ( response.rooms.join[room].ephemeral && response.rooms.join[room].ephemeral.events ) {
                var ephemerals = response.rooms.join[room].ephemeral.events
                // Go through all ephemerals
                for ( var i = 0; i < ephemerals.length; i++ ) {
                    // Is this a typing event?
                    if ( ephemerals[ i ].type === "m.typing" ) {
                        var user_ids = ephemerals[ i ].content.user_ids
                        // If the user is typing, remove his id from the list of typing users
                        var ownTyping = user_ids.indexOf( matrix.matrixid )
                        if ( ownTyping !== -1 ) user_ids.splice( ownTyping, 1 )
                        // Call the signal
                        chatTypingEvent ( room, user_ids )
                    }
                }
            }
        }
    }


    // Handling the synchronization events starts with the rooms
    function handleRooms ( rooms, membership ) {
        for ( var id in rooms ) {
            var room = rooms[id]

            if ( membership !== "leave" ) {
                // Update the
                transaction.executeSql ("INSERT OR REPLACE INTO Chats VALUES(?, ?, COALESCE((SELECT topic FROM Chats WHERE id='" + id + "'), ''), ?, ?, ?, COALESCE((SELECT prev_batch FROM Chats WHERE id='" + id + "'), ''))",
                [ id,
                membership,
                (room.unread_notifications && room.unread_notifications.highlight_count || 0),
                (room.unread_notifications && room.unread_notifications.notification_count || 0),
                (room.timeline ? (room.timeline.limited ? 1 : 0) : 0) ])

                // Handle now all room events and save them in the database
                if ( room.state ) handleRoomEvents ( id, room.state.events, "state", room )
                if ( room.invite_state ) handleRoomEvents ( id, room.invite_state.events, "invite_state", room )
                if ( room.timeline ) {
                    // Is the timeline limited? Then all previous messages should be
                    // removed from the database!
                    if ( room.timeline.limited ) {
                        transaction.executeSql ("DELETE FROM Events WHERE roomsid='" + id + "'")
                        transaction.executeSql ("UPDATE Chats SET prev_batch='" + room.timeline.prev_batch + "' WHERE id='" + id + "'")
                    }
                    handleRoomEvents ( id, room.timeline.events, "timeline", room )
                }
            }
            else {
                transaction.executeSql ( "DELETE FROM Chats WHERE id='" + id + "'")
                transaction.executeSql ( "DELETE FROM Users WHERE roomsid='" + id + "'")
                transaction.executeSql ( "DELETE FROM Events WHERE roomsid='" + id + "'")
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
                transaction.executeSql ( "INSERT OR IGNORE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?)",
                [ event.event_id,
                roomid,
                event.origin_server_ts,
                event.sender,
                event.content.body || null,
                event.content.msgtype || null,
                event.type,
                JSON.stringify(event.content) ])
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

            // This event means, that someone joined the room, has left the room
            // or has changed his nickname
            else if ( event.type === "m.room.member" ) {
                if ( type === "state" ) {
                    if ( !room.timeline ) continue
                    var found = false
                    for ( var t = 0; t < room.timeline.events.length; t++ ) {
                        if ( room.timeline.events[t].sender === event.state_key ) {
                            found = true
                            break
                        }
                    }
                    if ( !found ) continue
                }
                transaction.executeSql( "INSERT OR REPLACE INTO Users VALUES(?, ?, ?, ?, ?)",
                [ roomid,
                event.state_key,
                event.content.membership,
                event.content.displayname,
                event.content.avatar_url ])
                if ( event.state_key === matrix.matrixid) {
                    settings.avatar_url = event.content.avatar_url
                    settings.displayname = event.content.displayname
                }
            }
        }
    }
}
