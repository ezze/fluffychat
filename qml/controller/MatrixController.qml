import QtQuick 2.4
import Ubuntu.Components 1.3

/* =============================== MATRIX CONTROLLER ===============================

The matrix controller handles all requests to the matrix server. There are also
functions to login, logout and to autologin, when there are saved login
credentials
*/

Item {

    property var matrixid: settings.server ? "@" + settings.username + ":" + settings.server.split(":")[0] : null

    // The online status (bool)
    property var onlineStatus: false

    // The list of the current active requests, to prevent multiple same requests
    property var activeRequests: []

    // Check if there are username, password and domain saved from a previous
    // session and autoconnect with them. If not, then just go to the login Page.
    function init () {

        if ( settings.token ) {
            if ( tabletMode ) mainStack.push(Qt.resolvedUrl("../pages/BlankPage.qml"))
            else mainStack.push(Qt.resolvedUrl("../pages/ChatListPage.qml"))
            onlineStatus = true
            usernames.getById(matrix.matrixid, "", function (name) { settings.displayname = name } )
            events.init ()
        }
        else {
            mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
        }
    }


    // Login and set username, token and server! Needs to be done, before anything else
    function login ( newUsername, newPassword, newServer, newDeviceName, callback, error_callback, status_callback ) {

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
            settings.server = newServer.toLowerCase()
            settings.deviceName = newDeviceName
            settings.dbversion = storage.version
            onlineStatus = true
            events.init ()
            if ( callback ) callback ( response )
        }

        var onError = function ( response ) {
            settings.username = settings.server = settings.deviceName = undefined
            if ( error_callback ) error_callback ( response )
        }
        xmlRequest ( "POST", data, "/client/r0/login", onLogged, error_callback, status_callback )
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
        settings.username = settings.server = settings.token = settings.pusherIsSet = settings.deviceID = settings.deviceName = settings.displayname = settings.avatar_url = settings.since = undefined
        mainStack.clear ()
        mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
    }

    function get ( action, data, callback, error_callback, status_callback ) {
        return xmlRequest ( "GET", data, action, callback, error_callback, status_callback )
    }

    function post ( action, data, callback, error_callback, status_callback) {
        return xmlRequest ( "POST", data, action, callback, error_callback, status_callback )
    }

    function put ( action, file, callback, error_callback, status_callback ) {
        return xmlRequest ( "PUT", file, action, callback, error_callback, status_callback )
    }

    // Needs the name remove, because delete is reserved
    function remove ( action, file, callback, error_callback, status_callback ) {
        return xmlRequest ( "DELETE", file, action, callback, error_callback, status_callback )
    }

    function xmlRequest ( type, data, action, callback, error_callback, status_callback ) {

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

        var requestUrl = "https://" + settings.server + "/_matrix" + action + getData
        var longPolling = (data != null && data.timeout)
        http.open( type, requestUrl, true);
        http.setRequestHeader('Content-type', 'application/json; charset=utf-8')
        http.timeout = defaultTimeout
        if ( settings.token ) http.setRequestHeader('Authorization', 'Bearer ' + settings.token);
        http.onreadystatechange = function() {
            if ( status_callback ) status_callback ( http.readyState )
            if (http.readyState === XMLHttpRequest.DONE) {
                timer.stop ()
                var index = activeRequests.indexOf(checksum);
                activeRequests.splice( index, 1 )
                if ( !longPolling ) progressBarRequests--
                if ( progressBarRequests < 0 ) progressBarRequests = 0
                try {
                    var responseType = http.getResponseHeader("Content-Type")
                    if ( http.responseText === "" ) throw( "No connection to the homeserver 😕" )
                    if ( responseType === "application/json" ) {
                        var response = JSON.parse(http.responseText)
                        if ( "errcode" in response ) throw response
                        if ( callback ) callback( response )
                    }
                    else if ( responseType = "image/png" ) {
                        if ( callback ) callback( http.responseText )
                    }
                }
                catch ( error ) {
                console.error("There was an error: When calling ", requestUrl, " With data: ", JSON.stringify(data), " Error-Report: ", error/*, http.responseText*/)
                    if ( typeof error === "string" ) error = {"errcode": "ERROR", "error": error}
                    if ( error.errcode === "M_UNKNOWN_TOKEN" ) reset ()
                    if ( !error_callback && error === "offline" && settings.token ) {
                        onlineStatus = false
                        toast.show (i18n.tr("No connection to the homeserver 😕"))
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

        timer.interval = (longPolling || action == "/client/r0/sync") ? longPollingTimeout+2000 : defaultTimeout
        timer.repeat = false
        timer.triggered.connect(function () {
            if (http.readyState === XMLHttpRequest.OPENED) http.abort ()
        })
        timer.start();
        http.send( JSON.stringify( postData ) );

        return http
    }


    function upload ( path, callback, error_callback ) {
        console.log("Uploading ...", path)
        var pathparts = path.split("/")
        var filename = pathparts [ pathparts.length - 1 ]
        var type = filename.split(".")[1]

        // Send the blob to the server
        var requestUrl = "https://" + settings.server + "/_matrix/media/r0/upload?filename=" + filename
        //Fluffychat.upload ( path, requestUrl, 'Bearer ' + settings.token )
        callback ( "Ready ..." )
    }


    function getThumbnailFromMxc ( mxc, width, height ) {
        if ( mxc === undefined ) return ""

        var mxcID = mxc.replace("mxc://","")
        return "https://" + settings.server + "/_matrix/media/r0/thumbnail/" + mxcID + "/?width=" + width + "&height=" + height + "&method=crop"
    }



    function getImageLinkFromMxc ( mxc ) {
        if ( mxc === undefined ) return ""
        var mxcID = mxc.replace("mxc://","")
        return "https://" + settings.server + "/_matrix/media/r0/download/" + mxcID + "/"
    }




}
