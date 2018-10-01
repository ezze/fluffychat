import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Rectangle {

    color: theme.palette.normal.background
    anchors.fill: parent
    visible: false
    property bool stateVisible: false
    z: 12

    Icon {
        id: icon
        anchors.centerIn: parent
        width: units.gu(4)
        height: width
        name: "edit-clear"
    }

    Label {
        id: label
        elide: Text.ElideMiddle
        anchors.top: icon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: i18n.tr("Please restart your device to complete the update!" )
        wrapMode: Text.Wrap
    }

}
