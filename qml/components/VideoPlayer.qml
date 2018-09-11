import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtMultimedia 5.4

Rectangle {

    id: videoPlayer
    anchors.fill: parent
    visible: false
    color: Qt.rgba(0,0,0,0.9)
    z: 12

    MouseArea {
        anchors.fill: parent
        onClicked: imageViewer.visible = false
    }

    FcPageHeader {
        id: header
        z: 20
        title: ""
        leadingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "close"
                onTriggered: {
                    video.stop ()
                    video.source = ""
                    videoPlayer.visible = false
                }
            }]
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "document-save-as"
                onTriggered: Qt.openUrlExternally( media.getLinkFromMxc ( mxc ) )
            }]
        }
    }

    property var mxc: ""

    function show ( new_mxc ) {
        mxc = new_mxc
        video.source = media.getLinkFromMxc ( mxc )
        visible = true
        video.play ()
    }


    Video {
        z: 21
        id: video
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        //fillMode: Output.PreserveAspectCrop
        MouseArea {
            anchors.fill: parent
            onClicked: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
        }
        focus: true
        Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
        Keys.onLeftPressed: video.seek(video.position - 5000)
        Keys.onRightPressed: video.seek(video.position + 5000)
    }
}
