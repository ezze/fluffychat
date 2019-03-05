import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Row {
    width: parent.width
    height: parent.width / 2
    spacing: units.gu(2)

    property var avatar_url: ""
    property var matrixid: ""
    property var displayname: ""

    property var presence: "offline"
    property var last_active_ago: 0
    property var currently_active: false

    Rectangle {
        height: parent.height
        width: 1
        color: "#00000000"
    }

    Avatar {  // Useravatar
        id: avatarImage
        name: matrixid
        height: parent.height - units.gu(3)
        width: height
        mxc: avatar_url
        onClickFunction: function () {
            imageViewer.show ( mxc )
        }
    }

    Column {
        width: parent.height - units.gu(3)
        anchors.verticalCenter: parent.verticalCenter
        Label {
            text: i18n.tr("Username:")
            width: parent.width
            wrapMode: Text.Wrap
            font.bold: true
        }
        Label {
            text: matrixid
            width: parent.width
            wrapMode: Text.Wrap
        }
        Label {
            text: " "
            width: parent.width
        }
        Label {
            text: i18n.tr("Displayname:")
            width: parent.width
            wrapMode: Text.Wrap
            font.bold: true
        }
        Label {
            width: parent.width
            wrapMode: Text.Wrap
            text: displayname
        }
        Label {
            text: " "
            width: parent.width
        }
        Label {
            text: presence === "online" ? i18n.tr("Online:") : (presence === "offline" ? i18n.tr("Offline") : presence)
            width: parent.width
            wrapMode: Text.Wrap
            font.bold: true
            visible: matrixid !== settings.matrixid
            color: presence === "online" ? UbuntuColors.green : "#888888"
        }
        Label {
            text: currently_active ? i18n.tr("Currently active") : (last_active_ago !== 0 ? i18n.tr("Last seen: %1").arg( stamp.getChatTime ( presenceListItem.last_active_ago ) ) : " ")
            width: parent.width
            wrapMode: Text.Wrap
            visible: matrixid !== settings.matrixid
        }
        Label {
            text: " "
            width: parent.width
        }
    }

}
