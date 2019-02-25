import QtQuick 2.9
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

Rectangle {

    id: flyingButtonItem
    property var iconName: ""
    property alias mouseArea: mouseArea
    property var visibleState: false

    width: flyingButton.width
    height: flyingButton.height
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.margins: width / 2
    anchors.rightMargin: -(scrollDownButton.width * 2)
    color: "#00000000"
    opacity: 0.75

    UbuntuShape {
        id: flyingButton

        aspect: UbuntuShape.Flat
        width: units.gu(7)
        height: width
        relativeRadius: 0.75
        backgroundMode: UbuntuShape.VerticalGradient
        backgroundColor: mainLayout.mainColor
        secondaryBackgroundColor: mainLayout.brightMainColor
        z: 14
        MouseArea {
            id: mouseArea
            onPressed: parent.aspect = UbuntuShape.Inset
            onReleased: parent.aspect = UbuntuShape.Flat
            anchors.fill: parent
            enabled: parent.visible
        }
        Icon {
            name: iconName
            width: units.gu(3.5)
            height: width
            anchors.centerIn: parent
            z: 14
            color: "white"
        }
    }

    z: 2
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
