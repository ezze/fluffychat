import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Rectangle {
    id: loadingModal
    anchors.fill: parent
    z: 100
    color: Qt.rgba(0,0,0,0.75)
    visible: false

    property var max: 100
    property var value: 0

    Label {
        anchors.centerIn: parent
        color: "#FFFFFF"
        text: i18n.tr("Synchronizing… Please wait.")
    }

    ProgressBar {
        id: syncProgressBar
        anchors.top: parent.top
        minimumValue: 0
        maximumValue: max
        value: 0
        indeterminate: false
        width: parent.width
        visible: progressBarRequests > 0
    }
}
