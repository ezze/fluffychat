import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/MatrixNames.js" as MatrixNames

Rectangle {

    id: imageViewer
    anchors.fill: parent
    visible: false
    color: Qt.rgba(0,0,0,0.9)
    z: 12

    MouseArea {
        anchors.fill: parent
        onClicked: imageViewer.visible = false
    }

    MouseArea {
        anchors.fill: thumbnail
        onClicked: function () {}
    }

    PageHeader {
        id: header
        z: 20
        title: ""
        leadingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "close"
                onTriggered: imageViewer.visible = false
            }]
        }
        trailingActionBar {
            actions: [

            Action {
                id: downloadAction
                iconName: "document-save-as"
                onTriggered: download ( mxc, MatrixNames.getLinkFromMxc ( mxc ), contentHub.sharePicture )
            }
            ]
        }
    }

    property var mxc: ""

    function show ( new_mxc ) {
        mxc = new_mxc
        thumbnail.source = MatrixNames.getLinkFromMxc ( mxc )
        visible = true
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: imageViewer.width

            AnimatedImage {
                id: thumbnail
                width: parent.width
                height: width * ( sourceSize.height / sourceSize.width )
                fillMode: Image.PreserveAspectCrop
                visible: false
                onStatusChanged: if (status == Image.Ready) visible = true
            }
        }
    }

    ActivityIndicator {
        id: activity
        visible: !thumbnail.visible
        running: visible
        anchors.centerIn: parent
    }

}
