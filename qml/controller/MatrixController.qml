import QtQuick 2.9
import Ubuntu.Components 1.3

/* =============================== MATRIX CONTROLLER ===============================

The matrix controller handles all requests to the matrix server. There are also
functions to login, logout and to autologin, when there are saved login
credentials
*/

Item {

    // The online status (bool)
    property var onlineStatus: false

    // The list of the current active requests, to prevent multiple same requests
    property var activeRequests: []

    // Check if there are username, password and domain saved from a previous
    // session and autoconnect with them. If not, then just go to the login Page.
    function init () {

        mainStack.clear()
        if ( settings.token && settings.updateInfosFinished === version ) {
            if ( tabletMode ) mainStack.push(Qt.resolvedUrl("../pages/BlankPage.qml"))
            else mainStack.push(Qt.resolvedUrl("../pages/ChatListPage.qml"))
            onlineStatus = true
            events.init ()
        }
        else if ( settings.walkthroughFinished && settings.updateInfosFinished === version ){
            mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
        }
        else {
            mainStack.push(Qt.resolvedUrl("../pages/WalkthroughPage.qml"))
        }
    }


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
            settings.sendTypingNotification =
                settings.hideLessImportantEvents =
                settings.showMemberChangeEvents =
                settings.autoloadGifs = true
            onlineStatus = true
            events.init ()
            if ( callback ) callback ( response )
        }

        var onError = function ( response ) {
            resetSettings ()
            if ( error_callback ) error_callback ( response )
        }
        xmlRequest ( "POST", data, "/client/r0/login", onLogged, error_callback)
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
                            settings.server = newServer.toLowerCase()
                            settings.deviceName = newDeviceName
                            settings.dbversion = storage.version
                            onlineStatus = true
                            events.init ()
                            if ( callback ) callback ( response )
                        }, error_callback )
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
                events.init ()
                if ( callback ) callback ( response )
            }
        }

        xmlRequest ( "POST", data, "/client/r0/register", onResponse, onResponse )
    }

    function logout () {
        if ( events.syncRequest ) {
            events.abortSync = true
            events.syncRequest.abort ()
            events.abortSync = false
        }
        var callback = function () { post ( "/client/r0/logout", {}, reset, reset ) }
        pushclient.setPusher ( false, callback, callback )
    }


    function reset () {
        storage.drop ()
        onlineStatus = false
        resetSettings ()
        mainStack.clear ()
        mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
    }


    function joinChat (chat_id) {
        loadingScreen.visible = true
        matrix.post( "/client/r0/join/" + encodeURIComponent(chat_id), null, function ( response ) {
            loadingScreen.visible = true
            events.waitForSync()
            mainStack.toChat( response.room_id )
        } )
    }


    function resetSettings () {
        settings.username = settings.server = settings.token = settings.pushToken = settings.deviceID = settings.deviceName = settings.requestedArchive = settings.since = settings.matrixVersions = settings.matrixid = settings.lazy_load_members = undefined
    }


    function get ( action, data, callback, error_callback ) {
        return xmlRequest ( "GET", data, action, callback, error_callback )
    }

    function post ( action, data, callback, error_callback ) {
        return xmlRequest ( "POST", data, action, callback, error_callback )
    }

    function put ( action, file, callback, error_callback ) {
        return xmlRequest ( "PUT", file, action, callback, error_callback )
    }

    // Needs the name remove, because delete is reserved
    function remove ( action, file, callback, error_callback ) {
        return xmlRequest ( "DELETE", file, action, callback, error_callback )
    }

    function xmlRequest ( type, data, action, callback, error_callback ) {

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

        // Build the request
        var requestUrl = "https://" + server + "/_matrix" + action + getData
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
                    if ( !longPolling ) progressBarRequests--
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
                    if ( !error_callback && error.error === "CONNERROR" && settings.token ) {
                        onlineStatus = false
                        toast.show (i18n.tr("😕 No connection..."))
                    }
                    else if ( error.errcode === "M_CONSENT_NOT_GIVEN") {
                        loadingScreen.visible = false
                        if ( "consent_uri" in error ) {
                            consentUrl = error.consent_uri
                            var item = Qt.createComponent("../components/ConsentViewer.qml")
                            item.createObject(mainStack.currentPage, { })
                        }
                        else toast.show ( error.error )
                    }
                    else if ( error_callback ) error_callback ( error )
                    else if ( error.errcode !== undefined && error.error !== undefined ) toast.show ( error.errcode + ": " + error.error )
                }
            }
        }
        if ( !longPolling ) {
            progressBarRequests++
        }

        // Make timeout working in qml
        timer.stop ()
        timer.interval = (longPolling || isSyncRequest) ? longPollingTimeout*1.5 : defaultTimeout
        timer.repeat = false
        timer.triggered.connect(function () {
            if (http.readyState === XMLHttpRequest.OPENED) http.abort ()
        })
        timer.start();

        // Send the request now
        http.send( JSON.stringify( postData ) )

        return http
    }
}
