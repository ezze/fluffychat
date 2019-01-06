import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Rectangle {

    color: theme.palette.normal.background
    anchors.fill: parent
    visible: false
    property bool stateVisible: false
    z: 12

    MouseArea {
        anchors.fill: parent
        onClicked: Qt.quit()
    }

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
        text: i18n.tr("Please restart the app or if necessary restart the device to complete the update!" )
        wrapMode: Text.Wrap
    }

}
