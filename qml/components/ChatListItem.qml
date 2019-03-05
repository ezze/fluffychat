import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/ChatListItemActions.js" as ChatListItemActions

ListItem {
    id: chatListItem

    property var previousMessage: ""
    property var isUnread: (room.unread < room.origin_server_ts && room.sender !== matrix.matrixid) || room.membership === "invite"
    property var newNotifictaions: room.notification_count > 0

    visible: layout.title.text.toUpperCase().indexOf( searchField.displayText.toUpperCase() ) !== -1
    height: visible ? layout.height : 0

    color: activeChat === room.id ? highlightColor : mainBackgroundColor

    highlightColor: mainHighlightColor

    onClicked: ChatListItemActions.toChat ()

    ListItemLayout {
        id: layout
        width: parent.width - notificationBubble.width - highlightBubble.width
        title.text: ChatListItemActions.calcTitle ()
        title.font.bold: true
        title.color: mainLayout.mainFontColor
        subtitle.text: ChatListItemActions.calcSubtitle ()
        subtitle.color: mainLayout.mainFontColor
        subtitle.linkColor: subtitle.color

        Avatar {
            id: avatar
            SlotsLayout.position: SlotsLayout.Leading
            name: layout.title.text
            width: units.gu(7)
            mxc: ChatListItemActions.calcAvatar ()
            onClickFunction: function () { chatListItem.clicked () }
        }
    }


    Label {
        id: stampLabel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: units.gu(2.5)
        anchors.rightMargin: units.gu(2)
        text: MatrixNames.getChatTime ( room.origin_server_ts )
        color: mainLayout.mainFontColor
        textSize: Label.XSmall
        visible: text != ""
    }


    // Notification count bubble on the bottom right
    Rectangle {
        id: notificationBubble
        anchors.top: stampLabel.bottom
        anchors.right: parent.right
        anchors.topMargin: units.gu(0.5)
        anchors.rightMargin: units.gu(2)
        width: unreadLabel.width + units.gu(1)
        height: units.gu(2)
        color: newNotifictaions ? mainLayout.mainColor : mainLayout.mainBorderColor
        radius: units.gu(0.5)
        Label {
            id: unreadLabel
            anchors.centerIn: parent
            text: room.notification_count || "+1"
            textSize: Label.Small
            color: newNotifictaions ? UbuntuColors.porcelain : mainLayout.mainFontColor
        }
        visible: newNotifictaions || isUnread
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

    // Delete Button
    leadingActions: ListItemActions {
        actions: [
        Action {
            iconName: "edit-delete"
            text: i18n.tr("Leave this chat")
            onTriggered: ChatListItemActions.remove ()
        }
        ]
    }

}
