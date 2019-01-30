import QtQuick 2.9
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

Rectangle {

    id: flyingButtonItem
    property var iconName: ""
    property alias mouseArea: mouseArea

    width: flyingButton.width
    height: flyingButton.height
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.margins: width / 2
    color: "#00000000"

    UbuntuShape {
        id: flyingButton

        aspect: UbuntuShape.Flat
        width: units.gu(7)
        height: width
        relativeRadius: 0.75
        backgroundMode: UbuntuShape.VerticalGradient
        backgroundColor: settings.mainColor
        secondaryBackgroundColor: settings.brightMainColor
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

    DropShadow {
        id: shadow
        anchors.fill: flyingButton
        radius: 30.0
        samples: 17
        color: mainBorderColor
        source: flyingButton
        transitions: Transition {
            NumberAnimation { property: "radius"; duration: 300 }
        }
    }

}
