import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import "../scripts/MatrixNames.js" as MatrixNames

UbuntuShape {
    id: avatarRect
    width: units.gu(6)
    height: width
    relativeRadius: 0.75
    aspect: UbuntuShape.Flat
    backgroundMode: UbuntuShape.VerticalGradient
    backgroundColor: avatar.status === Image.Ready ? theme.palette.normal.background : MatrixNames.stringToDarkColor ( name )
    secondaryBackgroundColor: avatar.status === Image.Ready ? theme.palette.normal.background : MatrixNames.stringToColor ( name )
    z:1

    property var mxc: ""
    property var onClickFunction: function () { if ( mxc !== "" && mxc !== undefined && mxc !== null ) imageViewer.show ( mxc ) }
    property var name: ""


    MouseArea {
        anchors.fill: parent
        onClicked: onClickFunction !== null ? onClickFunction () : undefined
        onPressed: parent.aspect = UbuntuShape.Inset
        onReleased: parent.aspect = UbuntuShape.Flat
    }

    source: Image {
        id: avatar
        source:  mxc !== null && mxc !== "" && mxc !== undefined ? media.getThumbnailLinkFromMxc ( mxc, width, height ) : ""
        anchors.fill: parent
        cache: true
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        //asynchronous: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
        visible: status == Image.Ready
    }

    Label {
        anchors.centerIn: parent
        text: name.charAt(0) === "@" ? name.slice( 1, 3 ) : name.slice( 0, 2 )
        color: "white"
        textSize: parent.width > units.gu(6) ? Label.XLarge : ( parent.width > units.gu(4) ? Label.Large : Label.Small )
        z: 10
        visible: mxc === "" || avatar.status != Image.Ready
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: units.gu(4)
        visible: false
    }

}
