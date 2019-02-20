import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Connectivity 1.0
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/MessageFormats.js" as MessageFormats

/* =============================== MATRIX MODEL ===============================

The matrix model handles all requests to the matrix server. There are also
functions to login, logout and to autologin, when there are saved login
credentials
*/

Item {

    // The online status (bool)
    property var onlineStatus: false

    // Is the user logged or does he still need to login or register?
    property bool isLogged: settings.token !== null

    // The list of the current active requests, to prevent multiple same requests
    property var activeRequests: []

    property var online: Connectivity ? Connectivity.online : true
    onOnlineChanged: if ( online ) restartSync ()

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

    Component.onCompleted: if ( settings.token ) matrix.init ()


    // Login and set username, token and server! Needs to be done, before anything else
    function login ( newUsername, newPassword, newServer, newDeviceName, callback, error_callback) {

        settings.username = newUsername.toLowerCase()
        settings.server = newServer.toLowerCase()
        settings.deviceName = newDeviceName

        var data = {
            "initial_device_display_name": newDeviceName,
            "user": newUsername,
            "password": newPassword,
            "type": "m.login.password"
        }

        var onLogged = function ( response ) {
            settings.token = response.access_token
            settings.deviceID = response.device_id
            settings.username = (response.user_id.substr(1)).split(":")[0]
            settings.matrixid = response.user_id
            settings.server = newServer.toLowerCase()
            settings.deviceName = newDeviceName
            settings.dbversion = storage.version
            onlineStatus = true
            matrix.init ()
            if ( callback ) callback ( response )
        }

        var onError = function ( response ) {
            resetSettings ()
            if ( error_callback ) error_callback ( response )
        }
        xmlRequest ( "POST", data, "/client/r0/login", onLogged, error_callback, 2)
    }

    function register ( newUsername, newPassword, newServer, newDeviceName, callback, error_callback) {

        settings.username = newUsername.toLowerCase()
        settings.server = newServer.toLowerCase()
        settings.deviceName = newDeviceName

        var data = {
            "initial_device_display_name": newDeviceName,
            "username": newUsername,
            "password": newPassword
        }

        var onResponse = function ( response ) {
            // If error
            if ( response.errcode ) {
                if ( response.errcode !== "M_USER_IN_USE" ) resetSettings ()
                if ( error_callback ) error_callback ( response )
                return
            }

            // The homeserver requires additional authentication information.
            if ( response.flows ) {
                var forwarded = false
                for ( var i = 0; i < response.flows.length; i++ ) {

                    // If there is m.login.dummy, just retry the registration with
                    // the session id
                    if ( response.flows[i].stages[0] === "m.login.dummy" ) {
                        data.auth = {
                            "type": response.flows[i].stages[0],
                            "session": response.session
                        }
                        xmlRequest ( "POST", data, "/client/r0/register", function ( response ) {
                            settings.token = response.access_token
                            settings.deviceID = response.device_id
                            settings.username = (response.user_id.substr(1)).split(":")[0]
                            settings.matrixid = response.user_id
                            settings.server = newServer.toLowerCase()
                            settings.deviceName = newDeviceName
                            settings.dbversion = storage.version
                            onlineStatus = true
                            init ()
                            if ( callback ) callback ( response )
                        }, error_callback, 2 )
                        forwarded = true
                        break
                    }
                }

                // If there is no other choice, then the registration can not succeed
                if ( !forwarded ) throw ("ERROR")
            }

            // The account has been registered.
            else {
                settings.token = response.access_token
                settings.deviceID = response.device_id
                settings.username = (response.user_id.substr(1)).split(":")[0]
                settings.server = newServer.toLowerCase()
                settings.deviceName = newDeviceName
                settings.dbversion = storage.version
                onlineStatus = true
                init ()
                if ( callback ) callback ( response )
            }
        }

        xmlRequest ( "POST", data, "/client/r0/register", onResponse, onResponse, 2 )
    }

    function logout () {
        if ( syncRequest ) {
            abortSync = true
            syncRequest.abort ()
            abortSync = false
        }
        var callback = function () { post ( "/client/r0/logout", {}, reset, reset ) }
        pushclient.setPusher ( false, callback, callback )
    }


    function reset () {
        storage.drop ()
        onlineStatus = false
        resetSettings ()
        mainLayout.init ()
    }


    function joinChat (chat_id) {
        showConfirmDialog ( i18n.tr("Do you want to join this chat?").arg(chat_id), function () {
            loadingScreen.visible = true
            matrix.post( "/client/r0/join/" + encodeURIComponent(chat_id), null, function ( response ) {
                loadingScreen.visible = true
                matrix.waitForSync()
                mainLayout.toChat( response.room_id )
            }, null, 2 )
        } )

    }


    function sendMessage ( messageID, data, chat_id, success_callback, error_callback ) {
        var newMessageID = ""
        var callback = function () { if ( newMessageID !== "" ) success_callback ( newMessageID ) }
        if ( !online ) {
            storage.transaction ( "UPDATE Events SET status=-1 WHERE id='" + messageID + "'" )
            return error_callback ( "ERROR" )
        }

        var msgtype = data.msgtype === "m.sticker" ? data.msgtype : "m.room.message"
        matrix.put( "/client/r0/rooms/" + chat_id + "/send/" + msgtype + "/" + messageID, data, function ( response ) {
            userMetrics.sentMessages++

            newMessageID = response.event_id
            storage.transaction ( "SELECT * FROM Events WHERE id='" + response.event_id + "'", function ( res ) {
                if ( res.rows.length > 0 ) {
                    storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                }
                else {
                    storage.transaction ( "UPDATE Events SET id='" + response.event_id + "', status=1 WHERE id='" + messageID + "'", callback )
                }

            })
        }, function ( error ) {

            // If the user has no permissions or there is an internal server error,
            // the message gets deleted
            if ( error.errcode === "M_FORBIDDEN" ) {
                toast.show ( i18n.tr("You are not allowed to chat here.") )
                storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                if ( error_callback ) error_callback ("DELETE")
            }
            else if ( error.errcode === "M_UNKNOWN" ) {
                toast.show ( error.error )
                storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                if ( error_callback ) error_callback ("DELETE")
            }
            // Else: Try again in a few seconds
            else {
                storage.transaction ( "UPDATE Events SET status=-1 WHERE id='" + messageID + "'" )
                if ( error_callback ) error_callback ("ERROR")
            }

        } )
    }


    function resetSettings () {
        settings.username = settings.server = settings.token = settings.pushToken = settings.deviceID = settings.deviceName = settings.requestedArchive = settings.since = settings.matrixVersions = settings.matrixid = settings.lazy_load_members = undefined
    }


    function get ( action, data, callback, error_callback, priority ) {
        return xmlRequest ( "GET", data, action, callback, error_callback, priority )
    }

    function post ( action, data, callback, error_callback, priority ) {
        return xmlRequest ( "POST", data, action, callback, error_callback, priority )
    }

    function put ( action, data, callback, error_callback, priority ) {
        return xmlRequest ( "PUT", data, action, callback, error_callback, priority )
    }

    // Needs the name remove, because delete is reserved
    function remove ( action, file, callback, error_callback, priority ) {
        return xmlRequest ( "DELETE", file, action, callback, error_callback, priority )
    }

    function xmlRequest ( type, data, action, callback, error_callback, priority ) {

        if ( priority === undefined ) priority = 1

        // Check if the same request is actual sent
        var checksum = type + JSON.stringify(data) + action
        if ( activeRequests.indexOf(checksum) !== -1 ) return console.warn( "multiple request detected!" )
        else activeRequests.push ( checksum )

        var http = new XMLHttpRequest();
        var postData = {}
        var getData = ""

        if ( type === "GET" && data != null ) {
            for ( var i in data ) {
                getData += "&" + i + "=" + encodeURIComponent(data[i])
            }
            getData = "?" + getData.substr(1)
            //getData = getData.replace("")
        }
        else if ( data != null ) postData = data

        function Timer() {
            return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
        }
        var timer = new Timer()

        // Is this a request for the matrix server or the identity server?
        // This defaults to the matrix homeserver
        var server = settings.server
        if ( action.substring(0,10) === "/identity/" ) server = settings.id_server

        // Calculate the action url
        var requestUrl = action + getData
        if ( action.indexOf ( "https://" ) === -1 ) {
            requestUrl = "https://" + server + "/_matrix" + requestUrl
        }

        // Build the request
        var longPolling = (data != null && data.timeout)
        var isSyncRequest = (action === "/client/r0/sync")
        http.open( type, requestUrl, true);
        http.timeout = defaultTimeout
        if ( !(server === settings.id_server && type === "GET") ) http.setRequestHeader('Content-type', 'application/json; charset=utf-8')
        if ( server === settings.server && settings.token ) http.setRequestHeader('Authorization', 'Bearer ' + settings.token);
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                try {
                    var index = activeRequests.indexOf(checksum);
                    activeRequests.splice( index, 1 )
                    if ( !longPolling && priority > 0 ) progressBarRequests--
                    if ( priority > 1 ) waitDialogRequest = null
                    if ( progressBarRequests < 0 ) progressBarRequests = 0

                    if ( !timer.running ) throw( "CONNERROR" )
                    timer.stop ()

                    if ( http.responseText === "" ) throw( "CONNERROR" )

                    var responseType = http.getResponseHeader("Content-Type")
                    if ( responseType === "application/json" ) {
                        var response = JSON.parse(http.responseText)
                        if ( "errcode" in response || http.status !== 200 ) throw response
                        if ( callback ) callback( response )
                    }
                    else if ( responseType = "image/png" ) {
                        if ( callback ) callback( http.responseText )
                    }
                }
                catch ( error ) {
                    if ( !isSyncRequest ) console.error("There was an error: When calling ", type, requestUrl, " With data: ", JSON.stringify(data), " Error-Report: ", error, JSON.stringify(error))
                    if ( typeof error === "string" ) error = {"errcode": "ERROR", "error": error}
                    if ( error.errcode === "M_UNKNOWN_TOKEN" ) reset ()
                    if ( !error_callback && error.error === "CONNERROR" ) {
                        onlineStatus = false
                        toast.show (i18n.tr("😕 No connection..."))
                    }
                    else if ( error.errcode === "M_CONSENT_NOT_GIVEN") {
                        loadingScreen.visible = false
                        if ( "consent_uri" in error ) {
                            consentUrl = error.consent_uri
                            var item = Qt.createComponent("../components/ConsentViewer.qml")
                            item.createObject( root, { })
                        }
                        else toast.show ( error.error )
                    }
                    else if ( error_callback ) error_callback ( error )
                    else if ( error.errcode !== undefined && error.error !== undefined && priority > 0 ) toast.show ( error.error )
                }
            }
        }
        if ( !longPolling && priority > 0 ) {
            progressBarRequests++
        }
        if ( priority > 1 ) waitDialogRequest = http

        // Make timeout working in qml
        timer.stop ()
        timer.interval = (longPolling || isSyncRequest) ? longPollingTimeout*1.5 : defaultTimeout
        timer.repeat = false
        timer.triggered.connect(function () {
            if (http.readyState === XMLHttpRequest.OPENED) http.abort ()
        })
        timer.start();

        // Send the request now
        //console.log("[SEND]", requestUrl, JSON.stringify(postData))
        http.send( JSON.stringify( postData ) )

        return http
    }

    function init () {
        if ( !online ) return

        // Start synchronizing
        initialized = true
        if ( settings.since ) {
            waitForSync ()
            storage.transaction ( "UPDATE Events SET status=-1 WHERE status=0" )
            return sync ( 1 )
        }
        console.log("😉 Request the first synchronization")
        // Set the pusher if it is not set
        pushclient.updatePusher ()

        loadingScreen.visible = true
        storage.transaction ( "INSERT OR IGNORE INTO Users VALUES ( '" +
        settings.matrixid + "', '" + MatrixNames.transformFromId(settings.matrixid) + "', '', 'offline', 0, 0 )" )

        // Discover which features the server does support
        matrix.get ( "/client/versions", {}, function ( matrixVersions ) {
            settings.matrixVersions = matrixVersions.versions
            if ( "unstable_features" in matrixVersions && "m.lazy_load_members" in matrixVersions["unstable_features"] ) {
                settings.lazy_load_members = matrixVersions["unstable_features"]["m.lazy_load_members"] ? "true" : "false"
            }

            matrix.get( "/client/r0/sync", { filter: "{\"room\":{\"include_leave\":true,\"state\":{\"lazy_load_members\":%1}}}".arg(settings.lazy_load_members)}, function ( response ) {
                if ( waitingForSync ) progressBarRequests--
                handleEvents ( response )
                matrix.onlineStatus = true

                if ( !abortSync ) sync ()
            }, init, null, longPollingTimeout )
        })

    }


    function sync ( timeout ) {

        if ( settings.token === null || settings.token === undefined || abortSync ) return

        var data = { "since": settings.since, filter: "{\"room\":{\"state\":{\"lazy_load_members\":%1}}}".arg(settings.lazy_load_members) }

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
                    mainLayout.init ()
                }
                else {
                    if ( online ) restartSync ()
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
                    handlePresences ( response.presence)

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
            "VALUES('" + id + "', '" + membership + "', '', 0, 0, 0, '', '', '', 0, '', '', '', '', '', '', 0, 50, 50, 0, 50, 50, 0, 50, 100, 50, 50, 50, 100) ")

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

            if ( notification_count === 0 ) pushclient.clearPersistent ( id )

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
            if ( room.account_data ) handleRoomEvents ( id, room.account_data.events, "account_data", room )
        }
    }


    // Handle the presences
    function handlePresences ( presences ) {
        for ( var i = 0; i < presences.events.length; i++ ) {
            var pEvent = presences.events[i]
            var query = "UPDATE Users SET presence = '%1' ".arg( pEvent.content.presence )
            if ( pEvent.content.currently_active !== undefined ) query += ", currently_active = %1 ".arg( pEvent.content.currently_active ? "1" : "0" )
            if ( pEvent.content.last_active_ago !== undefined ) query += ", last_active_ago = %1 ".arg( (new Date().getTime() - pEvent.content.last_active_ago).toString() )
            query += "WHERE matrix_id = '%1'".arg(pEvent.sender)
            transaction.executeSql( query )
            newEvent ( pEvent.type, null, "presence", pEvent )
        }
    }


    // Handle ephemerals (message receipts)
    function handleEphemeral ( id, events ) {
        for ( var i = 0; i < events.length; i++ ) {
            if ( events[i].type === "m.receipt" ) {
                for ( var e in events[i].content ) {
                    for ( var user in events[i].content[e]["m.read"]) {
                        var timestamp = events[i].content[e]["m.read"][user].ts

                        // Call the newEvent signal for updating the GUI
                        newEvent ( events[i].type, id, "ephemeral", { ts: timestamp, user: user } )


                        if ( user === settings.matrixid ) {
                            transaction.executeSql( "UPDATE Chats SET unread=? WHERE id=?",
                            [ timestamp || new Date().getTime(),
                            id ])
                        }
                        else {
                            // Mark all previous received messages as seen
                            transaction.executeSql ( "UPDATE Events SET status=3 WHERE origin_server_ts<=" + timestamp +
                            " AND chat_id='" + id + "' AND status=2")
                        }
                    }
                }
            }
            if ( events[ i ].type === "m.typing" ) {
                var user_ids = events[ i ].content.user_ids
                // If the user is typing, remove his id from the list of typing users
                var ownTyping = user_ids.indexOf( settings.matrixid )
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
                if( event.content.body ) event.content_body = MessageFormats.formatText ( event.content.body )
                else event.content_body = null

                // Make unsigned part of the content
                if ( event.content.unsigned === undefined && event.unsigned !== undefined ) {
                    event.content.unsigned = event.unsigned
                }

                transaction.executeSql ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [ event.event_id,
                roomid,
                event.origin_server_ts,
                event.sender,
                event.state_key || event.sender,
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
                    MatrixNames.getChatAvatarById ( roomid, function ( displayname ) {
                        activeChatDisplayName = displayname
                    })
                }
            }


            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.topic" ) {
                transaction.executeSql( "UPDATE Chats SET description=? WHERE id=?",
                [ MessageFormats.formatText(event.content.topic) || "",
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
            if ( event.type === "m.room.avatar" ) {
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


            // This event means, that the aliases of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.fully_read" ) {
                transaction.executeSql( "UPDATE Chats SET fully_read=? WHERE id=?",
                [ event.content.event_id,
                roomid ])
            }


            // This event means, that someone joined the room, has left the room
            // or has changed his nickname
            else if ( event.type === "m.room.member" ) {


                // Update user database
                if ( event.content.membership !== "leave" && event.content.membership !== "ban" ) transaction.executeSql( "INSERT OR REPLACE INTO Users VALUES(?, ?, ?, 'offline', 0, 0)",
                [ event.state_key,
                event.content.displayname || MatrixNames.transformFromId(event.state_key),
                event.content.avatar_url || "" ])

                var memberInsertResult = transaction.executeSql( "INSERT OR IGNORE INTO Memberships VALUES('" + roomid + "', '" + event.state_key + "', ?, ?, ?, " +
                "COALESCE(" +
                "(SELECT power_level FROM Memberships WHERE chat_id='" + roomid + "' AND matrix_id='" + event.state_key + "'), " +
                "(SELECT power_user_default FROM Chats WHERE id='" + roomid + "')" +
                "))",
                [ event.content.displayname || "",
                event.content.avatar_url || "",
                event.content.membership ])

                if ( memberInsertResult.rowsAffected === 0 ) {
                    var queryStr = "UPDATE Memberships SET membership='" + event.content.membership + "'"
                    if ( event.content.displayname !== undefined ) queryStr += ", displayname='" + (event.content.displayname || "") + "' "
                    if ( event.content.avatar_url !== undefined ) queryStr += ", avatar_url='" + (event.content.avatar_url || "") + "' "
                    queryStr += " WHERE matrix_id='" + event.state_key + "' AND chat_id='" + roomid + "'"
                    transaction.executeSql( queryStr )
                }
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
                        var updateResult = transaction.executeSql( "UPDATE Memberships SET power_level=? WHERE matrix_id=? AND chat_id=?",
                        [ event.content.users[user],
                        user,
                        roomid ])
                        if ( updateResult.rowsAffected === 0 ) {
                            transaction.executeSql( "INSERT OR IGNORE INTO Memberships VALUES(?, ?, '', '', ?, ?)",
                            [ roomid,
                            user,
                            "unknown",
                            event.content.users[user] ])
                        }
                    }
                }
            }

            // Call the newEvent signal for updating the GUI
            newEvent ( event.type, roomid, type, event )
        }
    }
}
