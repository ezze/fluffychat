import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0


Rectangle {
    id: avatarRect
    // rounded corners for img
    width: units.gu(6)
    height: width
    color: Qt.hsla( 0, 0, 0.5, 0.15 ) //settings.darkmode ? UbuntuColors.jet : UbuntuColors.porcelain
    border.width: 1
    border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
    radius: units.gu(1)
    z:1
    clip: true

    property alias source: avatar.source
    property var mxc: ""
    property var onClickFunction: null
    property var name


    function stringToColor ( str ) {
        var number = 0
        for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
        number = (number % 100) / 100
        return Qt.hsla( number, 1, 0.4, 1 )
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
        color: stringToColor ( name ) //settings.mainColor
        textSize: Label.Large
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
