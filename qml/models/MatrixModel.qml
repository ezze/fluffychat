import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0
import Qt.labs.settings 1.0

/* =============================== MATRIX MODEL ===============================

The matrix model handles all requests to the matrix server. There are also
functions to login, logout and to autologin, when there are saved login
credentials
*/

Item {
    id: matrix

    // The priority of a request:
    // LOW: The request is in the background. Errors will be ignored and the
    // waiting for an answer counter will not be increased.
    // MEDIUM: Increase the waiting for an answer counter
    // HIGH: Trigger the signals to block the GUI until there is an answer
    // SYNC: Special priority for synchronization requests.
    readonly property var _PRIORITY: { "SYNC": -1, "LOW": 0, "NORMAL": 1, "HIGH": 2 }

    // The number of requests the client is waiting for an answer.
    property int waitingForAnswer: 0

    // If there is a request which should bock the UI, this property will be set.
    property var blockUIRequest: null

    // The homeserver of the user
    property string server: ""

    // The username is the local part of the matrix id
    property string username: ""

    // The matrix id of the username (can be different from @username:server)
    property string matrixid: "@%1:%2".arg(matrix.username).arg(matrix.server)

    // The ID server maps the emails and phone numbers to matrix IDs
    property string id_server: defaultIDServer

    // The device ID is an unique identifier for this device
    property string deviceID: ""

    // The device name is a human readable identifier for this device
    property string deviceName: ""

    // Which version of the matrix specification does this server support?
    property var matrixVersions: []

    // Wheither the server supports lazy load members
    property string lazy_load_members: "true"

    // This points to the position in the synchronization history
    property string prevBatch: ""

    // Chat settings: Send typing notification?
    property var sendTypingNotification: true

    // Chat settings: Hide less important events?
    property var hideLessImportantEvents: true

    // Chat settings: Autoload gifs?
    property var autoloadGifs: false

    // The two country ISO name and phone code:
    property var countryCode: i18n.tr("USA")
    property var countryTel: i18n.tr("1")

    // This is the access token for the matrix client. When it is undefined, then
    // the user needs to sign in first
    property string token: ""
    onTokenChanged: isLogged = token !== ""

    property bool isLogged: token !== ""
    onIsLoggedChanged: matrix.init ()

    // The list of the current active requests, to prevent multiple same requests
    property var activeRequests: []

    property var online: Connectivity ? Connectivity.online : true
    onOnlineChanged: if ( online ) restartSync ()

    // Save this properties in the settings
    Settings {
        property alias token: matrix.token
        property alias prevBatch: matrix.prevBatch
        property alias server: matrix.server
        property alias username: matrix.username
        property alias matrixid: matrix.matrixid
        property alias id_server: matrix.id_server
        property alias deviceID: matrix.deviceID
        property alias deviceName: matrix.deviceName
        property alias matrixVersions: matrix.matrixVersions
        property alias lazy_load_members: matrix.lazy_load_members
        property alias sendTypingNotification: matrix.sendTypingNotification
        property alias hideLessImportantEvents: matrix.hideLessImportantEvents
        property alias autoloadGifs: matrix.autoloadGifs
        property alias countryCode: matrix.countryCode
        property alias countryTel: matrix.countryTel
    }

    // This should be shown in the GUI for example as a toast
    signal error ( var error )

    /* The newEvent signal is the most importent signal in this concept. Every time
    * the app receives a new synchronization, this event is called for every signal
    * to update the GUI. For example, for a new message, it is called:
    * onNewEvent( "m.room.message", "!chat_id:server.com", "timeline", {sender: "@bob:server.com", body: "Hello world"} )
    */
    signal newEvent ( var type, var chat_id, var eventType, var eventContent )
    onNewEvent: console.log("💬[Event] From: '%1', Type: '%2' (%3)".arg(chat_id).arg(eventType).arg(type) )

    /* Outside of the events there are updates for the global chat states which
    * are handled by this signal:
    */
    signal newChatUpdate ( var chat_id, var membership, var notification_count, var highlight_count, var limitedTimeline, var prevBatch )

    property var syncRequest: null
    property var initialized: false
    property var abortSync: false


    // Login and set username, token and server! Needs to be done, before anything else
    function login ( newUsername, newPassword, newServer, newDeviceName, callback, error_callback) {

        matrix.username = newUsername.toLowerCase()
        matrix.server = newServer.toLowerCase()
        matrix.deviceName = newDeviceName

        var data = {
            "initial_device_display_name": newDeviceName,
            "user": newUsername,
            "password": newPassword,
            "type": "m.login.password"
        }

        var onLogged = function ( response ) {
            matrix.deviceID = response.device_id
            matrix.username = (response.user_id.substr(1)).split(":")[0]
            matrix.matrixid = response.user_id
            matrix.token = response.access_token
            if ( callback ) callback ( response )
        }

        xmlRequest ( "POST", data, "/client/r0/login", onLogged, error_callback, 2)
    }


    function register ( newUsername, newPassword, newServer, newDeviceName, callback, error_callback) {

        matrix.username = newUsername.toLowerCase()
        matrix.server = newServer.toLowerCase()
        matrix.deviceName = newDeviceName

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
                        var onRegisteredCallback = function ( response ) {
                            matrix.token = response.access_token
                            matrix.deviceID = response.device_id
                            matrix.username = (response.user_id.substr(1)).split(":")[0]
                            matrix.matrixid = response.user_id
                            if ( callback ) callback ( response )
                        }
                        xmlRequest ( "POST", data, "/client/r0/register", onRegisteredCallback, error_callback, 2 )
                        forwarded = true
                        break
                    }
                }

                // If there is no other choice, then the registration can not succeed
                if ( !forwarded ) throw ("ERROR")
            }

            // The account has been registered.
            else {
                matrix.token = response.access_token
                matrix.deviceID = response.device_id
                matrix.username = (response.user_id.substr(1)).split(":")[0]
                matrix.server = newServer.toLowerCase()
                matrix.deviceName = newDeviceName
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
        post ( "/client/r0/logout", {}, reset, reset, 2 )
    }


    function reset () {
        resetSettings ()
        mainLayout.init ()
    }


    // TODO: Move into chat list model!
    function joinChat (chat_id) {
        showConfirmDialog ( i18n.tr("Do you want to join this chat?").arg(chat_id), function () {
            matrix.post( "/client/r0/join/" + encodeURIComponent(chat_id), null, function ( response ) {
                matrix.waitForSync()
                mainLayout.toChat( response.room_id )
            }, null, 2 )
        } )
    }


    // TODO: Move into room model!
    function sendMessage ( messageID, data, chat_id, success_callback, error_callback ) {
        var newMessageID = ""
        if ( !online ) {
            storage.query ( "UPDATE Events SET status=-1 WHERE id=?", [ messageID ] )
            return error_callback ( "ERROR" )
        }

        var msgtype = data.msgtype === "m.sticker" ? data.msgtype : "m.room.message"

        var sendCallback = function ( response ) {
            userMetrics.sentMessages++

            newMessageID = response.event_id
            var res = storage.query ( "SELECT * FROM Events WHERE id=?", [ response.event_id ] )
            if ( res.rows.length > 0 ) {
                storage.query ( "DELETE FROM Events WHERE id=?", [ messageID ] )
            }
            else {
                storage.query ( "UPDATE Events SET id=?, status=1 WHERE id=?", [ response.event_id, messageID ] )
            }
            if ( newMessageID !== "" ) success_callback ( newMessageID )
        }

        var errorCallback = function ( error ) {

            // If the user has no permissions or there is an internal server error,
            // the message gets deleted
            if ( error.errcode === "M_FORBIDDEN" ) {
                toast.show ( i18n.tr("You are not allowed to chat here.") )
                storage.query ( "DELETE FROM Events WHERE id=?", [ messageID ] )
                if ( error_callback ) error_callback ("DELETE")
            }
            else if ( error.errcode === "M_UNKNOWN" ) {
                toast.show ( error.error )
                storage.query ( "DELETE FROM Events WHERE id=?", [ messageID ] )
                if ( error_callback ) error_callback ("DELETE")
            }
            // Else: Try again in a few seconds
            else {
                storage.query ( "UPDATE Events SET status=-1 WHERE id=?", [ messageID ] )
                if ( error_callback ) error_callback ("ERROR")
            }

        }

        matrix.put( "/client/r0/rooms/" + chat_id + "/send/" + msgtype + "/" + messageID, data, sendCallback, errorCallback )
    }


    function resetSettings () {
        matrix.token = ""
        matrix.username = matrix.server = matrix.deviceID = matrix.deviceName = matrix.prevBatch = matrix.matrixVersions = matrix.matrixid = matrix.lazy_load_members = ""
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

        if ( priority === undefined ) priority = _PRIORITY.MEDIUM

        // Check if the same request is actual sent
        var checksum = type + JSON.stringify(data) + action
        if ( activeRequests.indexOf(checksum) !== -1 ) return console.warn( "❌[Error] Multiple requests detected: %1".arg(action) )
        else activeRequests.push ( checksum )

        var http = new XMLHttpRequest();
        var postData = {}
        var getData = ""

        if ( type === "GET" && data != null ) {
            for ( var i in data ) {
                getData += "&" + i + "=" + encodeURIComponent(data[i])
            }
            getData = "?" + getData.substr(1)
        }
        else if ( data != null ) postData = data

        function Timer() {
            return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
        }
        var timer = new Timer()

        // Is this a request for the matrix server or the identity server?
        // This defaults to the matrix homeserver
        var server = matrix.server
        if ( action.substring(0,10) === "/identity/" ) server = matrix.id_server

        // Calculate the action url
        var requestUrl = action + getData
        if ( action.indexOf ( "https://" ) === -1 ) {
            requestUrl = "https://" + server + "/_matrix" + requestUrl
        }

        // Build the request
        var longPolling = (data != null && data.timeout)
        http.open( type, requestUrl, true)
        http.timeout = defaultTimeout
        if ( !(server === matrix.id_server && type === "GET") ) http.setRequestHeader('Content-type', 'application/json; charset=utf-8')
        if ( server === matrix.server && matrix.token ) http.setRequestHeader('Authorization', 'Bearer ' + matrix.token)

        // Handle responses
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                try {
                    // First: Remove the request from the list of active requests
                    // and update the waiting for an answer counter
                    var index = activeRequests.indexOf(checksum);
                    activeRequests.splice( index, 1 )

                    if ( !longPolling && priority > _PRIORITY.LOW ) waitingForAnswer--
                    if ( priority === _PRIORITY.HIGH ) blockUIRequest = null
                    if ( waitingForAnswer < 0 ) waitingForAnswer = 0

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
                    if ( priority !== _PRIORITY.SYNC && !error_callback ) console.error("❌[Error] Request:", type, requestUrl, JSON.stringify(data), " Error-Report: ", JSON.stringify(error))
                    if ( typeof error === "string" ) error = {"errcode": "ERROR", "error": error}
                    if ( error.errcode === "M_UNKNOWN_TOKEN" ) reset ()
                    if ( !error_callback && error.error === "CONNERROR" ) {
                        error (i18n.tr("😕 No connection..."))
                    }
                    else if ( error.errcode === "M_CONSENT_NOT_GIVEN") {
                        if ( "consent_uri" in error ) {
                            consentUrl = error.consent_uri
                            var item = Qt.createComponent("../components/ConsentViewer.qml")
                            item.createObject( root, { })
                        }
                        else error ( error.error )
                    }
                    else if ( error_callback ) error_callback ( error )
                    else if ( error.errcode !== undefined && error.error !== undefined && priority > _PRIORITY.LOW ) error ( error.error )
                }
            }
        }
        if ( !longPolling && priority > _PRIORITY.LOW ) {
            waitingForAnswer++
        }
        if ( priority === _PRIORITY.HIGH ) blockUIRequest = http

        // Make timeout working in qml
        timer.stop ()
        timer.interval = (longPolling || priority === _PRIORITY.SYNC) ? longPollingTimeout*1.5 : defaultTimeout
        timer.repeat = false
        timer.triggered.connect(function () {
            if (http.readyState === XMLHttpRequest.OPENED) http.abort ()
        })
        timer.start();

        // Send the request now
        if ( priority !== _PRIORITY.SYNC ) console.log("📨[Send]", action)
        http.send( JSON.stringify( postData ) )

        return http
    }

    function init () {
        // Compatible with old versions TODO: Repair this
        /*if ( settings.token && settings.token !== "" ) {
        matrix.token = settings.token
        if ( settings.server ) matrix.server = settings.server
        if ( settings.username ) matrix.username = settings.username
        if ( settings.matrixid ) matrix.matrixid = settings.matrixid
        if ( settings.id_server ) matrix.id_server = settings.id_server
        if ( settings.deviceID ) matrix.deviceID = settings.deviceID
        if ( settings.deviceName ) matrix.deviceName = settings.deviceName
        if ( settings.countryCode ) matrix.countryCode = settings.countryCode
        if ( settings.countryTel ) matrix.countryTel = settings.countryTel
        settings.token = ""
    }*/

    if ( matrix.token === "" ) return

    // Start synchronizing
    initialized = true
    if ( matrix.prevBatch !== "" ) {
        console.log("👷[Init] Init the matrix synchronization")
        waitForSync ()
        return sync ( 1 )
    }

    console.log("👷[Init] Request the first matrix synchronizaton")

    var onFristSyncResponse = function ( response ) {
        if ( waitingForSync ) waitingForAnswer--
        handleEvents ( response )

        if ( !abortSync ) sync ()
    }

    var onVersionsResponse = function ( matrixVersions ) {
        matrix.matrixVersions = matrixVersions.versions
        if ( "unstable_features" in matrixVersions && "m.lazy_load_members" in matrixVersions["unstable_features"] ) {
            matrix.lazy_load_members = matrixVersions["unstable_features"]["m.lazy_load_members"] ? "true" : "false"
        }
        // Start the first synchronization
        matrix.get( "/client/r0/sync", { filter: "{\"room\":{\"include_leave\":true,\"state\":{\"lazy_load_members\":%1}}}".arg(matrix.lazy_load_members)}, onFristSyncResponse, init, _PRIORITY.HIGH )
    }

    // Discover which features the server does support
    matrix.get ( "/client/versions", {}, onVersionsResponse, init)

}


function sync ( timeout ) {
    if ( matrix.token === null || matrix.token === undefined || abortSync ) return

    var data = { "since": matrix.prevBatch, filter: "{\"room\":{\"state\":{\"lazy_load_members\":%1}}}".arg(matrix.lazy_load_members) }

    if ( !timeout ) data.timeout = longPollingTimeout

    syncRequest = matrix.get ("/client/r0/sync", data, function ( response ) {

        if ( waitingForSync ) waitingForAnswer--
        waitingForSync = false
        if ( matrix.token ) {
            handleEvents ( response )
            sync ()
        }
    }, function ( error ) {
        if ( !abortSync && matrix.token !== undefined ) {
            if ( error.errcode === "M_INVALID" ) {
                mainLayout.init ()
            }
            else {
                if ( online ) restartSync ()
                else console.error ( i18n.tr("You are offline 😕") )
            }
        }
    }, _PRIORITY.SYNC );
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
    waitingForAnswer++
}


function stopWaitForSync () {
    if ( !waitingForSync ) return
    waitingForSync = false
    waitingForAnswer--
}


// This function starts handling the events, saving new data in the storage,
// deleting data, updating data and call signals
function handleEvents ( response ) {

    //console.log( "[Sync details]", JSON.stringify( response ) )
    var changed = false
    var timecount = new Date().getTime()
    try {
        handleRooms ( response.rooms.join, "join" )
        handleRooms ( response.rooms.leave, "leave" )
        handleRooms ( response.rooms.invite, "invite" )
        handlePresences ( response.presence)
        matrix.prevBatch = response.next_batch
        //console.log("[Sync performance] ", new Date().getTime() - timecount )
    }
    catch ( e ) {
        toast.show ( i18n.tr("😰 A critical error has occurred! Sorry, the connection to the server has ended! Please report this bug on: https://github.com/ChristianPauly/fluffychat/issues/new. Error details: %1").arg(e) )
        console.log ( "❌[Critical error]",e )
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

        var highlight_count = (room.unread_notifications && room.unread_notifications.highlight_count || 0)
        var notification_count = (room.unread_notifications && room.unread_notifications.notification_count || 0)
        var limitedTimeline = (room.timeline ? (room.timeline.limited ? 1 : 0) : 0)

        newChatUpdate ( id, membership, notification_count, highlight_count, limitedTimeline, room.timeline.prev_batch )

        // Handle now all room events and save them in the database
        if ( room.state ) handleRoomEvents ( id, room.state.events, "state", room )
        if ( room.invite_state ) handleRoomEvents ( id, room.invite_state.events, "invite_state", room )
        if ( room.timeline ) handleRoomEvents ( id, room.timeline.events, "timeline", room )
        if ( room.ephemeral ) handleEphemeral ( id, room.ephemeral.events )
        if ( room.account_data ) handleRoomEvents ( id, room.account_data.events, "account_data", room )
    }
}
// Handle the presences
function handlePresences ( presences ) {
    for ( var i = 0; i < presences.events.length; i++ ) {
        var pEvent = presences.events[i]
        newEvent ( pEvent.type, pEvent.sender, "presence", pEvent )
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
// Handle room events
function handleRoomEvents ( roomid, events, type ) {
    // We go through the events array
    for ( var i = 0; i < events.length; i++ ) {
        newEvent ( events[i].type, roomid, type, events[i] )
    }
}


}
