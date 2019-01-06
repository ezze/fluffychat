import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Rectangle {

    color: theme.palette.normal.background
    anchors.fill: root
    visible: false
    property bool stateVisible: false
    z: 12

    Icon {
        id: icon
        anchors.centerIn: parent
        width: units.gu(8)
        height: width
        name: "sync-updating"
    }

    Label {
        id: label
        elide: Text.ElideMiddle
        anchors.top: icon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - units.gu(4)
        horizontalAlignment: Text.AlignHCenter
        text: i18n.tr("Loading chats\nThis can take a few minutes…")
        wrapMode: Text.Wrap
    }

}
