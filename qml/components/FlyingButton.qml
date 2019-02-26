import QtQuick 2.9
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

Rectangle {

    id: flyingButtonItem
    property var iconName: ""
    property alias mouseArea: mouseArea
    property var visibleState: false

    width: units.gu(6)
    height: width
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.margins: width / 2
    anchors.rightMargin: -(scrollDownButton.width * 2)
    color: theme.palette.normal.background
    border.width: 1
    border.color: mainLayout.mainFontColor
    opacity: 0.9
    radius: width

    z: 14
    MouseArea {
        id: mouseArea
        onPressed: parent.color = "#888888"
        onReleased: parent.color = theme.palette.normal.background
        anchors.fill: parent
        enabled: parent.visible
    }
    Icon {
        name: iconName
        width: units.gu(3.5)
        height: width
        anchors.centerIn: parent
        z: 14
        color: mainLayout.mainFontColor
    }

    transitions: Transition {
        SpringAnimation {
            spring: 2
            damping: 0.2
            properties: "anchors.rightMargin"
        }
    }
    states: State {
        name: "visible"
        when: visibleState
        PropertyChanges {
            target: scrollDownButton
            anchors.rightMargin: scrollDownButton.width / 2
        }
    }

}
