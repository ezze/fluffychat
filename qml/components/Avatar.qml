import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0


Rectangle {
    id: avatarRect
    // rounded corners for img
    width: units.gu(6)
    height: width
    color: avatar.status === Image.Ready ? UbuntuColors.porcelain : usernames.stringToColor ( name )
    radius: width / 6
    z:1
    clip: true

    property alias source: avatar.source
    property var mxc: ""
    property var onClickFunction: function () { if ( mxc !== "" && mxc !== undefined && mxc !== null ) imageViewer.show ( mxc ) }
    property var name: ""


    MouseArea {
        anchors.fill: parent
        onClicked: onClickFunction !== null ? onClickFunction () : undefined
    }



    Image {
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
        radius: parent.radius
        visible: false
    }

}
