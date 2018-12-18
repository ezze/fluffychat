import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Rectangle {
    id: task
    property var name: ""
    property var iconName: "contact"
    property var contactProposal: false
    width: mainStackWidth / 4
    height: width

    Avatar {
        id: avatar
        name: iconName
        width: parent.width / 1.5
        height: width
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Label {
        anchors.top: avatar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: name
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            activeChat = name
            mainStack.push (Qt.resolvedUrl("../pages/UserSettingsPage.qml"))
        }
    }

}
