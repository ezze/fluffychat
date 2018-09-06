import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    id: chatListItem

    property var timeorder: 0
    property var previousMessage: ""
    height: layout.height

    onClicked: {
        PopupUtils.close( dialogue )
        mainStack.toStart ()
        activeChat = room.id
        activeChatTypingUsers = []
        mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
        if ( room.notification_count > 0 ) matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + room.eventsid, null )
    }

    ListItemLayout {
        id: layout
        width: parent.width - notificationBubble.width - highlightBubble.width
        title.text: i18n.tr("Unknown chat")
        title.font.bold: true
        title.color: room.membership === "invite" ? settings.mainColor : (settings.darkmode ? "white" : "black")

        Avatar {
            id: avatar
            SlotsLayout.position: SlotsLayout.Leading
            name: room.topic || room.id
            mxc: room.avatar_url || ""
        }

        Component.onCompleted: {

            // Get the room name
            if ( room.topic !== "" ) layout.title.text = room.topic
            else roomnames.getById ( room.id, function (displayname) {
                layout.title.text = displayname
                avatar.name = displayname
                // Is there a typing notification?
                if ( room.typing && room.typing.length > 0 ) {
                    layout.subtitle.text = usernames.getTypingDisplayString ( room.typing, displayname )
                }
            })

            // Get the room avatar if single chat
            if ( avatar.mxc === "") roomnames.getAvatarFromSingleChat ( room.id, function ( avatar_url ) {
                avatar.mxc = avatar_url
            } )
        }
    }


    Label {
        id: stampLabel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.gu(2)
        text: stamp.getChatTime ( room.origin_server_ts )
        textSize: Label.XSmall
        visible: text != ""
    }


    // Notification count bubble on the bottom right
    Rectangle {
        id: notificationBubble
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: units.gu(2)
        width: unreadLabel.width + units.gu(1)
        height: units.gu(2)
        color: settings.mainColor
        radius: units.gu(0.5)
        Label {
            id: unreadLabel
            anchors.centerIn: parent
            text: room.notification_count || "0"
            textSize: Label.Small
            color: UbuntuColors.porcelain
        }
        visible: unreadLabel.text != "0"
    }


    Icon {
        id: highlightBubble
        visible: room.highlight_count > 0
        name: "dialog-warning-symbolic"
        anchors.right: notificationBubble.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(2)
        anchors.rightMargin: units.gu(0.5)
        width: units.gu(2)
        height: width
    }


}
