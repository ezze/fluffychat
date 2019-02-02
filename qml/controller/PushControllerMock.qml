import QtQuick 2.0

QtObject {
    id: pushClient

    property var errorReport: null
    property var pushUrl: "https://push.ubports.com:5003/_matrix/push/r0/notify"
    property var deviceName: "FluffyChat %1 on Ubuntu Touch".arg(version)

    function updatePusher () {
        console.warn("updatePusher(): ignored because Ubuntu.PushNotifications is not installed");
    }

    function pusherror ( reason ) {
        console.warn("pusherror(): ignored because Ubuntu.PushNotifications is not installed");
    }

    function newNotification ( message ) {
        console.warn("newNotification(): ignored because Ubuntu.PushNotifications is not installed");
    }

    function setPusher () {
        console.warn("setPusher(): ignored because Ubuntu.PushNotifications is not installed");
    }

    function clearPersistent () {
        console.warn("clearPersistent(): ignored because Ubuntu.PushNotifications is not installed");
    }
}
