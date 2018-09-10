import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0


Rectangle {
    id: avatarRect
    // rounded corners for img
    width: units.gu(6)
    height: width
    color: settings.darkmode ? Qt.hsla( 0, 0, 0.04, 1 ) : Qt.hsla( 0, 0, 0.96, 1 )
    border.width: 1
    border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
    radius: width / 6
    z:1
    clip: true

    property alias source: avatar.source
    property var mxc: ""
    property var onClickFunction: function () { if ( mxc !== "" ) imageViewer.show ( mxc ) }
    property var name: ""


    function stringToColor ( str ) {
        var number = 0
        for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
        number = (number % 100) / 100
        return Qt.hsla( number, 1, 0.35, 1 )
    }


    MouseArea {
        anchors.fill: parent
        onClicked: onClickFunction !== null ? onClickFunction () : undefined
    }


    Image {
        id: avatar
        source:  mxc !== null && mxc !== "" ? media.getThumbnailLinkFromMxc ( mxc, width, height ) : ""
        anchors.fill: parent
        cache: true
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
        visible: status == Image.Ready
    }


    Label {
        anchors.centerIn: parent
        text: name.slice( 0, 2 )
        color: stringToColor ( name )
        textSize: parent.width > units.gu(6) ? Label.XLarge : (parent.width < units.gu(6) ? Label.Small : Label.Large)
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
