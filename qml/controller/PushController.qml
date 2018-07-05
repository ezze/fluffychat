import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.PushNotifications 0.1
import Qt.labs.settings 1.0

PushClient {
    id: pushClient

    property var errorReport: null

    function pusherror ( reason ) {
        console.warn("PUSHERROR",reason)
        if ( reason === "bad auth" ) {
            errorReport = i18n.tr("Please login to Ubuntu One to receive push notifications!")
        }
        else errorReport = reason
    }

    function newNotification ( message ) {
        if ( message == "" ) return
        try {
            message = JSON.parse ( message )
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
        else {
            var data = {
                "app_display_name": "FluffyChat",
                "app_id": appId,
                "append": true,
                "data": {
                    "url": "https://janian.de:7000"
                },
                "device_display_name": "UbuntuPhone",
                "lang": "en",
                "kind": intent ? "http" : null,
                "profile_tag": "xxyyzz",
                "pushkey": pushtoken
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
