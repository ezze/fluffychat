import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0
import "../components"

ListItem {
    id: message
    property var isStateEvent: event.type !== "m.room.message" && event.type !== "m.room.encrypted" && event.type !== "m.sticker"
    property var isMediaEvent: [ "m.file", "m.image", "m.video", "m.audio" ].indexOf( event.content.msgtype ) !== -1 || event.type === "m.sticker"
    property var isImage: !isStateEvent && (event.content.msgtype === "m.image" || event.type === "m.sticker")
    property var imageVisible: image.showGif || image.showThumbnail ? true : false
    property var sent: event.sender.toLowerCase() === settings.matrixid.toLowerCase()
    property var isLeftSideEvent: !sent || isStateEvent
    property var sending: sent && event.status === msg_status.SENDING
    property var senderDisplayname: activeChatMembers[event.sender].displayname!==undefined ? activeChatMembers[event.sender].displayname : usernames.transformFromId(event.sender)
    property var bgcolor: (isStateEvent ? (settings.darkmode ? "black" : "white") :
    (!sent ? settings.darkmode ? "#191A15" : UbuntuColors.porcelain :
    (event.status < msg_status.SEEN ? settings.brighterMainColor : settings.mainColor)))

    divider.visible: false
    highlightColor: "#00000000"

    width: mainStackWidth
    height: (isMediaEvent ? messageBubble.height + units.gu(1) :  // Media event height is calculated by the message bubble height
        messageLabel.height + units.gu(2.75 + !isStateEvent*1.5))   // Text content is calculated by the label height for better performenace

        color: "transparent"

        onPressAndHold: toast.show ( i18n.tr("Swipe to the left or the right for actions. 😉"))

        // Notification-settings Button
        trailingActions: ListItemActions {
            actions: [
            Action {
                text: i18n.tr("Try to send again")
                iconName: "send"
                visible: event.status === msg_status.ERROR
                onTriggered: {
                    var body = event.content_body
                    storage.transaction ( "DELETE FROM Events WHERE id='" + event.id + "'")
                    removeEvent ( event.id )
                    chatPage.send ( body )
                }
            },
            Action {
                text: i18n.tr("Reply")
                iconName: "mail-reply"
                visible: !isStateEvent && event.status >= msg_status.SENT && canSendMessages
                onTriggered: {
                    chatPage.replyEvent = event
                    messageTextField.focus = true
                }
            },
            Action {
                text: i18n.tr("Share")
                iconName: "share"
                visible: !isStateEvent && event.type === "m.room.message" && [ "m.file", "m.image", "m.video", "m.audio" ].indexOf( event.content.msgtype ) === -1
                onTriggered: shareController.shareTextIntern ("%1 (%2): %3".arg( senderDisplayname ).arg( stamp.getChatTime (event.origin_server_ts) ).arg( event.content.body ))
            },
            Action {
                text: i18n.tr("Copy text")
                iconName: "edit-copy"
                visible: !isStateEvent && event.type === "m.room.message" && [ "m.file", "m.image", "m.video", "m.audio" ].indexOf( event.content.msgtype ) === -1
                onTriggered: {
                    shareController.toClipboard ( event.content.body )
                    toast.show( i18n.tr("Text has been copied to the clipboard") )
                }
            },
            Action {
                text: i18n.tr("Add to sticker collection")
                iconName: "add"
                visible: event.type === "m.sticker" || event.content.type === "m.image"
                onTriggered: {
                    showConfirmDialog ( i18n.tr("Add to sticker collection?"), function () {
                        storage.query( "INSERT OR IGNORE INTO Media VALUES(?,?,?,?)", [
                        "image/gif",
                        event.content.url,
                        event.content.url,
                        event.content.url
                        ], function ( result ) {
                            if ( result.rowsAffected == 0 ) toast.show (i18n.tr("Already added as sticker"))
                            else toast.show (i18n.tr("Added as sticker"))
                        })
                    } )
                }
            }
            ]
        }

        // Delete Button
        leadingActions: ListItemActions {
            actions: [
            Action {
                text: i18n.tr("Remove")
                iconName: "edit-delete"
                enabled: ((canRedact || sent) && event.status >= msg_status.SENT || event.status === msg_status.ERROR)
                onTriggered: {
                    if ( event.status === msg_status.ERROR ) {
                        storage.transaction ( "DELETE FROM Events WHERE id='" + event.id + "'")
                        removeEvent ( event.id )
                    }
                    else showConfirmDialog ( i18n.tr("Are you sure?"), function () {
                        matrix.put( "/client/r0/rooms/%1/redact/%2/%3"
                        .arg(activeChat)
                        .arg(event.id)
                        .arg(new Date().getTime()) )
                    })
                }
            }
            ]
        }


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
            mxc: opacity ? activeChatMembers[event.sender].avatar_url : ""
            name: senderDisplayname
            anchors.left: isLeftSideEvent ? parent.left : undefined
            anchors.right: !isLeftSideEvent ? parent.right : undefined
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gu(1)
            anchors.leftMargin: units.gu(1)
            anchors.rightMargin: units.gu(1)
            opacity: (event.sameSender || isStateEvent) ? 0 : 1
            width: isStateEvent ? units.gu(3) : units.gu(5)
            onClickFunction: function () {
                if ( !opacity ) return
                activeUser = event.sender
                usernames.showUserSettings ( event.sender )
            }
        }




        Rectangle {
            id: messageBubble
            anchors.left: isLeftSideEvent && !isStateEvent ? avatar.right : undefined
            anchors.right: !isLeftSideEvent && !isStateEvent ? avatar.left : undefined
            anchors.bottom: parent.bottom
            anchors.bottomMargin: !imageVisible*units.gu(1)
            anchors.leftMargin: units.gu(1)
            anchors.rightMargin: units.gu(1)
            anchors.horizontalCenter: isStateEvent ? parent.horizontalCenter : undefined
            border.color: mainBorderColor
            border.width: isStateEvent

            opacity: isStateEvent ? 0.75 : 1
            z: 2
            color: imageVisible ? "#00000000" : bgcolor

            Behavior on color {
                ColorAnimation { from: settings.brighterMainColor; duration: 300 }
            }

            radius: units.gu(2)
            height: contentColumn.height + ( imageVisible ? units.gu(1) : (isStateEvent ? units.gu(1.5) : units.gu(2)) )
            width: contentColumn.width + ( imageVisible ? -1 : units.gu(2) )

            Rectangle {
                width: units.gu(2)
                height: width
                color: messageBubble.color
                visible: !isStateEvent && !event.sameSender
                anchors.left: !sent ? parent.left : undefined
                anchors.right: sent ? parent.right : undefined
                anchors.bottom: parent.bottom
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: parent.radius
                visible: false
            }

            Column {
                id: contentColumn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: isStateEvent ? units.gu(0.75) : units.gu(1)


                /* ====================IMAGE OR STICKER====================
                * If the message is an image or a sticker, then show this, following:
                * http://yuml.me/diagram/plain/activity/(start)-><a>[Gif-Image && autload active]->(Show full MXC), <a>[else]-><b>[Thumbnail exists]->(Show thumbnail), <b>[Thumbnail is null]->(Show "Show Image"-Button)               */
                Rectangle {
                    id: image
                    color: "#00000000"
                    width: thumbnail.status === Image.Ready ? thumbnail.width : (showButton ? showImageButton.width : (showGif && gif.status === Image.Ready ? gif.width : height*(9/16)))
                    height: visible * (!showButton ? units.gu(30) : showImageButton.height)
                    visible: !isStateEvent && (event.content.msgtype === "m.image" || event.type === "m.sticker")
                    property var hasThumbnail: event.content.info && event.content.info.thumbnail_url
                    property var isGif: visible && event.content.info && event.content.info.mimetype && event.content.info.mimetype === "image/gif"
                    property var showGif: isGif && settings.autoloadGifs
                    property var showThumbnail: visible && !showGif && (hasThumbnail || settings.autoloadGifs)
                    property var showButton: visible && !showGif && !showThumbnail

                    MouseArea {
                        anchors.fill: parent
                        onClicked: imageViewer.show ( event.content.url )
                    }

                    Image {
                        id: thumbnail
                        source: visible ? (image.hasThumbnail ? media.getThumbnailLinkFromMxc ( event.content.info.thumbnail_url, Math.round (height), Math.round (height) ) :
                        media.getLinkFromMxc ( event.content.url )) : ""
                        property var onlyOneError: true
                        height: parent.height
                        width: Math.min ( height * ( sourceSize.width / sourceSize.height ), mainStackWidth - units.gu(3) - avatar.width)
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: mask
                        }
                        visible: image.showThumbnail
                        opacity: status === Image.Ready
                        cache: true
                    }

                    AnimatedImage {
                        id: gif
                        source: image.showGif ? media.getLinkFromMxc ( event.content.url ) : ""
                        height: parent.height
                        width: Math.min ( height * ( sourceSize.width / sourceSize.height ), mainStackWidth - units.gu(3) - avatar.width)
                        fillMode: Image.PreserveAspectCrop
                        visible: image.showGif
                        opacity: status === Image.Ready
                    }

                    ActivityIndicator {
                        visible: thumbnail.status === Image.Loading || (image.showGif && !gif.opacity && !image.showButton)
                        anchors.centerIn: parent
                        width: units.gu(2)
                        height: width
                        running: visible
                    }

                    Icon {
                        visible: !image.showButton && (thumbnail.status === Image.Error || gif.status === Image.Error)
                        anchors.centerIn: parent
                        width: units.gu(6)
                        height: width
                        name: "sync-error"
                    }

                    Button {
                        id: showImageButton
                        text: isGif ? i18n.tr("Load gif") : i18n.tr("Show image")
                        onClicked: image.showGif = true
                        visible: image.showButton
                        height: visible ? units.gu(4) : 0
                        width: visible ? units.gu(26) : 0
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1)
                        color: settings.brightMainColor
                    }
                }


                /*  ====================AUDIO MESSAGE====================
                */
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
                        onClicked: {
                            downloadDialog.filename = event.content_body
                            downloadDialog.downloadUrl = media.getLinkFromMxc ( event.content.url )
                            downloadDialog.shareFunc = shareController.shareAudio
                            downloadDialog.current = PopupUtils.open(downloadDialog)
                        }
                        width: units.gu(4)
                    }
                }


                /*  ====================VIDEO MESSAGE====================
                */
                /*MouseArea {
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
}*/


/*  ====================FILE MESSAGE====================
*/
Button {
    id: downloadButton
    color: settings.brightMainColor
    text: i18n.tr("Download: ") + event.content.body
    onClicked: {
        downloadDialog.filename = event.content_body
        downloadDialog.shareFunc = shareController.shareAll
        downloadDialog.downloadUrl = media.getLinkFromMxc ( event.content.url )
        downloadDialog.current = PopupUtils.open(downloadDialog)
    }
    visible: event.content.msgtype === "m.file" || event.content.msgtype === "m.video"
    height: visible ? units.gu(4) : 0
    width: visible ? units.gu(26) : 0
    anchors.left: parent.left
    anchors.leftMargin: units.gu(1)
}


/*  ====================TEXT MESSAGE====================
* In this label, the body of the matrix message is displayed. This label
* is main responsible for the width of the message bubble.
*/
Label {
    id: messageLabel
    opacity: isMediaEvent ? 0 : 1
    height: opacity ? undefined : 0
    text: isStateEvent ? displayEvents.getDisplay ( event ) + " - " + stamp.getChatTime ( event.origin_server_ts ) :
    (event.type === "m.room.encrypted" ? displayEvents.getDisplay ( event ) :
    event.content_body || event.content.body)
    color: (!sent || isStateEvent) ? (settings.darkmode ? "white" : "black") :
    (event.status < msg_status.SEEN ? settings.mainColor : "white")
    linkColor: settings.brightMainColor
    Behavior on color {
        ColorAnimation { from: settings.mainColor; duration: 300 }
    }
    wrapMode: Text.Wrap
    textFormat: Text.StyledText
    textSize: isStateEvent ? Label.XSmall :
    (event.content.msgtype === "m.fluffychat.whisper" ? Label.XxSmall :
    (event.content.msgtype === "m.fluffychat.roar" ? Label.XLarge : Label.Medium))

    font.italic: event.content.msgtype === "m.emote"
    anchors.left: parent.left
    anchors.topMargin: isStateEvent ? units.gu(0.5) : units.gu(1)
    anchors.leftMargin: units.gu(1)
    anchors.bottomMargin: isStateEvent ? units.gu(0.5) : 0
    onLinkActivated: uriController.openUrlExternally ( link )
    // Intital calculation of the max width and display URL's and
    // make sure, that the label text is not empty for the correct
    // height calculation.
    Component.onCompleted: {
        if ( !event.content_body ) event.content_body = event.content.body
        var maxWidth = message.width - avatar.width - units.gu(5)
        if ( width > maxWidth ) width = maxWidth
        if ( text === "" ) text = " "
        if ( event.content.msgtype === "m.emote" ) text = senderDisplayname + " " + text
    }
}

Rectangle {
    color: imageVisible ? bgcolor : "#00000000"
    height: metaLabelRow.height + imageVisible*units.gu(0.5)
    width: metaLabelRow.width + imageVisible*units.gu(0.5)
    anchors.left: sent ? undefined : parent.left
    anchors.leftMargin: !imageVisible*units.gu(1)
    anchors.right: sent ? parent.right : undefined
    anchors.rightMargin: imageVisible ? 0 : -units.gu(1)
    radius: width / 10

    Row {
        id: metaLabelRow
        spacing: units.gu(0.25)
        anchors.centerIn: parent

        // This label is for the meta-informations, which means it displays the
        // display name of the sender of this message and the time.
        Label {
            id: metaLabel
            text: {
                // Show the senders displayname only if its not the user him-/herself.
                ((event.sender !== settings.matrixid) && senderDisplayname !== activeChatDisplayName ?
                ("<font color='" + usernames.stringToDarkColor ( senderDisplayname ) + "'><b>" + senderDisplayname + "</b></font> ")
                : "")
                + stamp.getChatTime ( event.origin_server_ts )
            }
            color: messageLabel.color
            textSize: Label.XxSmall
            visible: !isStateEvent
            wrapMode: Text.NoWrap

            // Check that the sender displayname is not too long
            Component.onCompleted: {
                if ( senderDisplayname.length > 40 ) {
                    senderDisplayname = senderDisplayname.substr(0,39)
                }
            }

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
            visible: !isStateEvent && sent && event.status !== msg_status.SENDING
            source: "../../assets/" +
            (event.status === msg_status.SEEN ? "seen" :
            (event.status === msg_status.RECEIVED ? "received" :
            (event.status === msg_status.ERROR ? "error" :
            (event.status === msg_status.HISTORY ? "received" : ""))))
            + ".svg"
            height: metaLabel.height
            color: event.status === msg_status.SENT ? messageBubble.color :
            (event.status === msg_status.ERROR ? UbuntuColors.red : metaLabel.color)
            width: height
        }
    }
}

}
}


}
