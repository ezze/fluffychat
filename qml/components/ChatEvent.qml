import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Rectangle {
    id: message
    //property var event
    property var isStateEvent: event.type !== "m.room.message" && event.type !== "m.sticker"
    property var isMediaEvent: [ "m.file", "m.image", "m.video", "m.audio" ].indexOf( event.content.msgtype ) !== -1
    property var isImage: !isStateEvent && (event.content.msgtype === "m.image" || event.type === "m.sticker") && event.content.info !== undefined && event.content.info.thumbnail_url !== undefined
    property var sent: event.sender.toLowerCase() === matrix.matrixid.toLowerCase()
    property var isLeftSideEvent: !sent || isStateEvent
    property var sending: sent && event.status === msg_status.SENDING

    width: mainStackWidth
    height: messageBubble.height + units.gu(1)
    color: "transparent"


    // When the width of the "window" changes (rotation for example) then the maxWidth
    // of the message label must be calculated new. There is currently no "maxwidth"
    // property in qml.
    onWidthChanged: {
        messageLabel.width = undefined
        var maxWidth = width - avatar.width - units.gu(5)
        if ( messageLabel.width > maxWidth ) messageLabel.width = maxWidth
        else messageLabel.width = undefined
    }


    Avatar {
        id: avatar
        mxc: chatMembers[event.sender] ? chatMembers[event.sender].avatar_url : ""
        name: chatMembers[event.sender] ? chatMembers[event.sender].displayname : usernames.transformFromId(event.sender)
        anchors.left: isLeftSideEvent ? parent.left : undefined
        anchors.right: !isLeftSideEvent ? parent.right : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        opacity: (event.sameSender && !isStateEvent) ? 0 : 1
        width: isStateEvent ? units.gu(3) : units.gu(6)
        onClickFunction: function () {
            if ( !opacity ) return
            activeUser = event.sender
            usernames.showUserSettings ( event.sender )
        }
    }


    MouseArea {
        width: messageBubble.width
        height: messageBubble.height
        anchors.left: isLeftSideEvent ? avatar.right : undefined
        anchors.right: !isLeftSideEvent ? avatar.left : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)

        onClicked: {
            if ( !isStateEvent && !thumbnail.visible && !contextualActions.visible ) {
                contextualActions.contextEvent = event
                contextualActions.show()
            }
        }
        Rectangle {
            id: messageBubble
            opacity: sending ? 0.66 : isStateEvent ? 0.75 : 1
            z: 2
            border.width: 0
            border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
            anchors.margins: units.gu(0.5)
            color: (sent || isStateEvent) ? "#FFFFFF" : settings.mainColor
            radius: units.gu(2)
            height: contentColumn.height + ( isImage ? units.gu(1) : (isStateEvent ? units.gu(1.5) : units.gu(2)) )
            width: contentColumn.width + units.gu(2)

            Column {
                id: contentColumn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: isStateEvent ? units.gu(0.75) : units.gu(1)

                MouseArea {
                    width: thumbnail.width
                    height: thumbnail.height
                    Image {
                        id: thumbnail
                        visible: !isStateEvent && (event.content.msgtype === "m.image" || event.type === "m.sticker") && event.content.info !== undefined && event.content.info.thumbnail_url !== undefined
                        width: visible ? Math.max( units.gu(24), messageLabel.width + units.gu(2) ) : 0
                        source: event.content.url ? media.getThumbnailLinkFromMxc ( event.content.info.thumbnail_url, 2*Math.round (width), 2*Math.round (width) ) : ""
                        height: width * ( sourceSize.height / sourceSize.width )
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: {
                            if ( status === Image.Error ) {
                                visible = false
                                downloadButton.visible = true
                            }
                        }
                    }
                    onClicked: imageViewer.show ( event.content.url )
                }


                Row {
                    id: audioPlayer
                    visible: event.content.msgtype === "m.audio"
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    spacing: units.gu(1)
                    width: visible ? undefined : 0
                    height: visible * units.gu(6)

                    Button {
                        id: playButton
                        anchors.verticalCenter: parent.verticalCenter
                        property var playing: false
                        color: "white"
                        iconName: playing ? "media-playback-pause" : "media-playback-start"
                        onClicked: {
                            if ( audio.source !== media.getLinkFromMxc ( event.content.url ) ) {
                                audio.source = media.getLinkFromMxc ( event.content.url )
                            }
                            if ( playing ) audio.pause ()
                            else audio.play ()
                            playing = !playing
                        }
                        width: units.gu(4)
                    }
                    Button {
                        id: stopButton
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        iconName: "media-playback-stop"
                        opacity: audio.source === media.getLinkFromMxc ( event.content.url ) && audio.position === 0 ? 0.75 : 1
                        onClicked: {
                            audio.stop ()
                            playButton.playing = false
                        }
                        width: units.gu(4)
                    }
                    Button {
                        id: downloadAudioButton
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        iconName: "document-save-as"
                        onClicked: Qt.openUrlExternally( media.getLinkFromMxc ( event.content.url ) )
                        width: units.gu(4)
                    }
                }

                MouseArea {
                    width: videoLink.width
                    height: videoLink.height
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    onClicked: videoPlayer.show ( event.content.url)
                    Rectangle {
                        id: videoLink
                        visible: event.content.msgtype === "m.video"
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#000000" }
                            GradientStop { position: 0.5; color: "#303030"}
                            GradientStop { position: 1.0; color: "#101010" }
                        }
                        width: visible * units.gu(32)
                        height: visible * units.gu(18)
                        radius: units.gu(0.5)
                        Icon {
                            name: "media-preview-start"
                            color: UbuntuColors.silk
                            anchors.centerIn: parent
                            width: units.gu(4)
                            height: width
                        }
                    }
                }


                Button {
                    id: downloadButton
                    text: i18n.tr("Download file: ") + event.content.body
                    onClicked: Qt.openUrlExternally( media.getLinkFromMxc ( event.content.url ) )
                    visible: [ "m.file", "m.image" ].indexOf( event.content.msgtype ) !== -1 && (event.content.info === undefined || event.content.info.thumbnail_url === undefined)
                    height: visible ? units.gu(4) : 0
                    width: visible ? undefined : 0
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                }


                // In this label, the body of the matrix message is displayed. This label
                // is main responsible for the width of the message bubble.
                Label {
                    id: messageLabel
                    opacity: (event.type === "m.sticker" || isMediaEvent) ? 0 : 1
                    height: opacity ? undefined : 0
                    text: isStateEvent ? displayEvents.getDisplay ( event ) + " <font color='" + UbuntuColors.silk + "'>" + stamp.getChatTime ( event.origin_server_ts ) + "</font>" :  event.content_body || event.content.body
                    color: (sent || isStateEvent) ? "black" : "white"
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText
                    textSize: isStateEvent ? Label.XSmall : Label.Medium
                    anchors.left: parent.left
                    anchors.topMargin: isStateEvent ? units.gu(0.5) : units.gu(1)
                    anchors.leftMargin: units.gu(1)
                    anchors.bottomMargin: isStateEvent ? units.gu(0.5) : 0
                    onLinkActivated: Qt.openUrlExternally(link)
                    // Intital calculation of the max width and display URL's
                    Component.onCompleted: {
                        if ( !event.content_body ) event.content_body = event.content.body
                        var maxWidth = message.width - avatar.width - units.gu(5)
                        if ( width > maxWidth ) width = maxWidth

                        if ( !isStateEvent ) {
                            var urlRegex = /(https?:\/\/[^\s]+)/g
                            var tempText = text || " "
                            if ( tempText === "" ) tempText = " "
                            tempText = text.replace(urlRegex, function(url) {
                                return '<a href="%1"><font color="%2">%1</font></a>'.arg(url).arg(messageLabel.color)
                            })
                            text = tempText
                        }
                    }
                }


                Row {
                    id: metaLabelRow
                    anchors.left: sent ? undefined : parent.left
                    anchors.leftMargin: units.gu(1)
                    anchors.right: sent ? parent.right : undefined
                    anchors.rightMargin: -units.gu(1)
                    spacing: units.gu(0.25)

                    // This label is for the meta-informations, which means it displays the
                    // display name of the sender of this message and the time.
                    Label {
                        id: metaLabel
                        text: (chatMembers[event.sender] ? chatMembers[event.sender].displayname : usernames.transformFromId(event.sender)) + " " + stamp.getChatTime ( event.origin_server_ts )
                        color: messageLabel.color
                        opacity: 0.66
                        textSize: Label.XSmall
                        visible: !isStateEvent
                    }
                    // When the message is just sending, then this activity indicator is visible
                    ActivityIndicator {
                        id: activity
                        visible: sending
                        running: visible
                        height: metaLabel.height
                        width: height
                    }
                    // When the message is received, there should be an icon
                    Icon {
                        id: statusIcon
                        visible: !isStateEvent && sent && event.status > 0
                        name: event.status === msg_status.SENT ? "sync-updating" : (event.status === msg_status.SEEN ? "contact" : (event.status === msg_status.HISTORY ? "clock" : "tick"))
                        height: metaLabel.height
                        color: "black"
                        width: height
                    }
                }
            }


        }
    }


}
