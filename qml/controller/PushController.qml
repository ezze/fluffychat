import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.PushNotifications 0.1
import Qt.labs.settings 1.0

PushClient {
    id: pushClient

    property var errorReport: null
    property var pushUrl: "https://push.ubports.com:5003/_matrix/push/r0/notify"
    property var deviceName: "FluffyChat %1 on Ubuntu Touch".arg(version)

    onTokenChanged: {
        if ( !settings.token ) return
        // Set the pusher if it is not set
        updatePusher ()
    }


    function updatePusher () {
        if ( token !== "" && (settings.pushToken !== token || settings.pushUrl !== pushUrl || settings.pushDeviceName !== deviceName) ) {
            console.log("👷 Trying to set pusher… '%1':'%2'".arg(settings.pushDeviceName).arg(deviceName))
            pushclient.setPusher ( true, function () {
                settings.pushToken = pushtoken
                settings.pushUrl = pushUrl
                settings.pushDeviceName = deviceName
                console.log("😊 Pusher is set!")
            }, function ( error ) {
                console.warn( "ERROR:", JSON.stringify(error))
                toast.show ( error.error )
            } )
        }
    }

    function pusherror ( reason ) {
        console.warn("PUSHERROR",reason)
        if ( reason === "bad auth" ) {
            errorReport = i18n.tr("Please log in to Ubuntu One to receive push notifications.")
            toast.show ( errorReport )
        }
        else errorReport = reason
    }

    function newNotification ( message ) {
        //console.log("==============================NEW NOTIFICATION==============================\n",message)
       if ( message == "" ) return
        try {
            // Clear the persistent notification if the user is in this room
            var room = message.room_name || message.sender_display_name || message.sender
            if ( room === activeChatDisplayName ) pushclient.clearPersistent ( room )
        }
        catch ( e ) {
            console.error ( message, e )
        }
    }

    Component.onCompleted: {
        notificationsChanged.connect(newNotification)
        error.connect(pusherror)
    }


    // This function will toggle the push notifications. It will set or kill a
    // pusher with the pushkey of this device. Also it will reset one push rule,
    // to provide full functionality of notifications. Sometimes, other clients
    // like Riot web set push rules, which disables all notifications.
    function setPusher ( intent, callback, error_callback ) {
        if ( intent && errorReport !== null ) {
            if ( error_callback ) error_callback ( {errcode: "NO_UBUNTUONE", error: errorReport} )
        }
        else if ( token === "" ) {
            if ( error_callback ) error_callback ( {errcode: "EMPTY_PUSHTOKEN", error: i18n.tr("Push notifications are disabled...")} )
        }
        else {
            var data = {
                "app_display_name": "FluffyChat",
                "app_id": appId,
                "append": true,
                "data": {
                    "url": pushUrl
                },
                "device_display_name": deviceName,
                "lang": "en",
                "kind": intent ? "http" : null,
                "profile_tag": "xxyyzz",
                "pushkey": token
            }
            matrix.post ( "/client/r0/pushers/set", data, function() {
                // This is a workaround for the problem with the riot web client, who disables the push notifications sometimes
                if ( intent ) matrix.put ( "/client/r0/pushrules/global/content/.m.rule.contains_user_name/enabled", { "enabled": true } )
                callback ()
            }, error_callback )
        }
    }

    appId: "fluffychat.christianpauly_fluffychat"

}
