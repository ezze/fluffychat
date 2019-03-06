import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/EventDescription.js" as EventDescription
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/ChatEventActions.js" as ItemActions
import "../scripts/MessageFormats.js" as MessageFormats

ListView {

    id: chatScrollView
    property alias count: model.count

    width: parent.width
    height: parent.height - 2 * chatInput.height
    anchors.bottom: chatInput.top
    verticalLayoutDirection: ListView.BottomToTop
    delegate: ListItem {
        id: message

        property var eventModel: event || {}

        property bool isStateEvent: eventModel.type !== "m.room.message" && eventModel.type !== "m.room.encrypted" && eventModel.type !== "m.sticker"
        property bool isMediaEvent: isImage || [ "m.file", "m.video", "m.audio" ].indexOf( eventModel.content.msgtype ) !== -1
        property bool isImage: !isStateEvent && (eventModel.content.msgtype === "m.image" || eventModel.type === "m.sticker")
        property bool imageVisible: image.showGif || image.showThumbnail ? true : false
        property bool sent: eventModel.sender.toLowerCase() === matrix.matrixid.toLowerCase()
        property bool isLeftSideEvent: !sent || isStateEvent
        property bool sending: sent && eventModel.status === msg_status.SENDING
        property string senderDisplayname: typeof activeChatMembers[eventModel.sender] !== "undefined" ? activeChatMembers[eventModel.sender].displayname : MatrixNames.transformFromId(eventModel.sender)
        property var bgcolor: ItemActions.calcBubbleBackground ( isStateEvent, sent, eventModel.status )
        property var lastEvent: index > 0 ? chatScrollView.model.get(index-1).event : null
        property var fontColor: (!sent || isStateEvent) ? mainLayout.mainFontColor :
        (eventModel.status < msg_status.SEEN ? mainLayout.mainColor : "white")
        property bool sameSender: lastEvent !== null ? lastEvent.sender === eventModel.sender : false

        divider.visible: false
        highlightColor: "#00000000"

        width: parent.width
        //height: messageBubble.height + units.gu(1)
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
                visible: eventModel.status === msg_status.ERROR
                onTriggered: ItemActions.resendMessage ( event )
            },
            Action {
                text: i18n.tr("Reply")
                iconName: "mail-reply"
                visible: !isStateEvent && eventModel.status >= msg_status.SENT && canSendMessages
                onTriggered: ItemActions.startReply ( event )
            },
            Action {
                text: i18n.tr("Copy text")
                iconName: "edit-copy"
                visible: !isStateEvent && eventModel.type === "m.room.message" && [ "m.file", "m.image", "m.video", "m.audio" ].indexOf( eventModel.content.msgtype ) === -1
                onTriggered: contentHub.toClipboard ( eventModel.content.body )
            },
            Action {
                text: i18n.tr("Add to sticker collection")
                iconName: "add"
                visible: eventModel.type === "m.sticker" || eventModel.content.type === "m.image"
                onTriggered: ItemActions.addAsSticker ( event )
            },
            Action {
                text: i18n.tr("Forward")
                iconName: "toolkit_chevron-ltr_4gu"
                visible: !isStateEvent
                onTriggered: ItemActions.share ( isMediaEvent, senderDisplayname, event )
            }
            ]
        }

        // Delete Button
        leadingActions: ListItemActions {
            actions: [
            Action {
                text: i18n.tr("Remove")
                iconName: "edit-delete"
                enabled: ((canRedact || sent) && eventModel.status >= msg_status.SENT || eventModel.status === msg_status.ERROR)
                onTriggered: ItemActions.removeEvent ( event )
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


        Loader {
            id: avatar
            anchors {
                left: isLeftSideEvent ? parent.left : undefined
                right: !isLeftSideEvent ? parent.right : undefined
                bottom: parent.bottom
                bottomMargin: units.gu(1)
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            width: isStateEvent ? units.gu(3) : units.gu(5)
            active: !sameSender && !isStateEvent
            sourceComponent: Avatar {
                id: avatarInstance
                mxc: opacity && typeof activeChatMembers[eventModel.sender] !== "undefined" ? activeChatMembers[eventModel.sender].avatar_url : ""
                name: senderDisplayname
                opacity: (sameSender || isStateEvent) ? 0 : 1
                onClickFunction: function () {
                    if ( opacity ) MatrixNames.showUserSettings ( eventModel.sender )
                }
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
            border.color: mainLayout.mainBorderColor
            border.width: isStateEvent

            opacity: isStateEvent ? 0.75 : 1
            z: 2
            color: imageVisible ? "transparent" : bgcolor

            Behavior on color {
                ColorAnimation { from: mainLayout.brighterMainColor; duration: 300 }
            }

            radius: units.gu(2)
            height: contentColumn.height + ( imageVisible ? units.gu(1) : (isStateEvent ? units.gu(1.5) : units.gu(2)) )
            width: contentColumn.width + ( imageVisible ? -1 : units.gu(2) )

            Rectangle {
                width: units.gu(2)
                height: width
                color: messageBubble.color
                visible: !isStateEvent && !sameSender
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
                Loader {
                    id: image
                    active: !isStateEvent && (eventModel.content.msgtype === "m.image" || eventModel.type === "m.sticker")
                    property bool hasThumbnail: active && eventModel.content.info && eventModel.content.info.thumbnail_url
                    property bool isGif: active && eventModel.content.info && eventModel.content.info.mimetype && eventModel.content.info.mimetype === "image/gif"
                    property bool showGif: isGif && matrix.autoloadGifs
                    property bool showThumbnail: visible && !showGif && (hasThumbnail || matrix.autoloadGifs)
                    property bool showButton: visible && !showGif && !showThumbnail

                    sourceComponent: Rectangle {
                        id: imageObj
                        color: "#00000000"
                        width: thumbnail.status === Image.Ready ? thumbnail.width : (showButton ? showImageButton.width : (showGif && gif.status === Image.Ready ? gif.width : height*(9/16)))
                        height: (!showButton ? units.gu(30) : showImageButton.height)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: imageViewer.show ( eventModel.content.url )
                        }

                        Image {
                            id: thumbnail
                            source: visible ? (image.hasThumbnail ? MatrixNames.getThumbnailLinkFromMxc ( eventModel.content.info.thumbnail_url, Math.round (height), Math.round (height) ) :
                            MatrixNames.getLinkFromMxc ( eventModel.content.url )) : ""
                            property var onlyOneError: true
                            height: parent.height
                            width: Math.min ( height * ( sourceSize.width / sourceSize.height ), message.width - units.gu(3) - avatar.width)
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
                            source: image.showGif ? MatrixNames.getLinkFromMxc ( eventModel.content.url ) : ""
                            height: parent.height
                            width: Math.min ( height * ( sourceSize.width / sourceSize.height ), message.width - units.gu(3) - avatar.width)
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
                            text: image.isGif ? i18n.tr("Load gif") : i18n.tr("Show image")
                            onClicked: image.showGif = true
                            visible: image.showButton
                            height: visible ? units.gu(4) : 0
                            width: visible ? units.gu(26) : 0
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(1)
                            color: mainLayout.brightMainColor
                        }
                    }
                }


                //  ====================AUDIO MESSAGE====================
                Loader {
                    active: eventModel.content.msgtype === "m.audio"
                    sourceComponent: Row {
                        id: audioPlayer
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
                            onClicked: ItemActions.toggleAudioPlayer ( event )
                            width: units.gu(4)
                        }
                        Button {
                            id: stopButton
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            iconName: "media-playback-stop"
                            opacity: audio.source === MatrixNames.getLinkFromMxc ( eventModel.content.url ) && audio.position === 0 ? 0.75 : 1
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
                                downloadDialog.filename = eventModel.content_body
                                downloadDialog.downloadUrl = MatrixNames.getLinkFromMxc ( eventModel.content.url )
                                downloadDialog.shareFunc = contentHub.shareAudio
                                downloadDialog.current = PopupUtils.open(downloadDialog)
                            }
                            width: units.gu(4)
                        }
                    }
                }


                //  ====================FILE MESSAGE====================
                Loader {
                    active: eventModel.content.msgtype === "m.file" || eventModel.content.msgtype === "m.video"
                    sourceComponent: Button {
                        id: downloadButton
                        color: mainLayout.brightMainColor
                        text: i18n.tr("Download: ") + eventModel.content.body
                        onClicked: {
                            downloadDialog.filename = eventModel.content_body
                            downloadDialog.shareFunc = contentHub.shareAll
                            downloadDialog.downloadUrl = MatrixNames.getLinkFromMxc ( eventModel.content.url )
                            downloadDialog.current = PopupUtils.open(downloadDialog)
                        }
                        height: visible ? units.gu(4) : 0
                        width: visible ? units.gu(26) : 0
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1)
                    }
                }

                /*  ====================TEXT MESSAGE====================
                * In this label, the body of the matrix message is displayed. This label
                * is main responsible for the width of the message bubble.
                */
                Loader {
                    id: messageLabel
                    active: !isMediaEvent
                    sourceComponent: Label {
                        id: messageLabel
                        text: isStateEvent ? EventDescription.getDisplay ( event ) + " - " + MatrixNames.getChatTime ( eventModel.origin_server_ts ) :
                        (eventModel.type === "m.room.encrypted" ? EventDescription.getDisplay ( event ) :
                        eventModel.content_body || eventModel.content.body)
                        color: fontColor
                        linkColor: mainLayout.brightMainColor
                        Behavior on color {
                            ColorAnimation { from: mainLayout.mainColor; duration: 300 }
                        }
                        wrapMode: Text.Wrap
                        textFormat: Text.StyledText
                        textSize: isStateEvent ? Label.XSmall :
                        (eventModel.content.msgtype === "m.fluffychat.whisper" ? Label.XxSmall :
                        (eventModel.content.msgtype === "m.fluffychat.roar" ? Label.XLarge : Label.Medium))

                        font.italic: eventModel.content.msgtype === "m.emote"
                        anchors.left: parent.left
                        anchors.topMargin: isStateEvent ? units.gu(0.5) : units.gu(1)
                        anchors.leftMargin: units.gu(1)
                        anchors.bottomMargin: isStateEvent ? units.gu(0.5) : 0
                        onLinkActivated: contentHub.openUrlExternally ( link )
                        // Intital calculation of the max width and display URL's and
                        // make sure, that the label text is not empty for the correct
                        // height calculation.
                        Component.onCompleted: {
                            if ( !eventModel.content_body ) eventModel.content_body = eventModel.content.body
                            var maxWidth = message.width - avatar.width - units.gu(5)
                            if ( width > maxWidth ) width = maxWidth
                            if ( text === "" ) text = " "
                            if ( eventModel.content.msgtype === "m.emote" ) text = senderDisplayname + " " + text
                        }
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
                                ((eventModel.sender !== matrix.matrixid) && senderDisplayname !== activeChatDisplayName ?
                                ("<font color='" + MatrixNames.stringToDarkColor ( senderDisplayname ) + "'><b>" + senderDisplayname + "</b></font> ")
                                : "")
                                + MatrixNames.getChatTime ( eventModel.origin_server_ts )
                            }
                            color: fontColor
                            textSize: Label.XxSmall
                            visible: !isStateEvent
                            wrapMode: Text.NoWrap
                            textFormat: Text.StyledText

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
                            visible: !isStateEvent && sent && eventModel.status !== msg_status.SENDING
                            source: "../../assets/" +
                            (eventModel.status === msg_status.SEEN ? "seen" :
                            (eventModel.status === msg_status.RECEIVED ? "received" :
                            (eventModel.status === msg_status.ERROR ? "error" :
                            (eventModel.status === msg_status.HISTORY ? "received" : "send"))))
                            + ".svg"
                            height: metaLabel.height
                            color: eventModel.status === msg_status.SENT ? messageBubble.color :
                            (eventModel.status === msg_status.ERROR ? UbuntuColors.red : metaLabel.color)
                            width: height
                        }
                    }
                }
            }
        }
    }

    model: ListModel { id: model }
    move: Transition {
        NumberAnimation { property: "opacity"; to:1; duration: 1 }
    }
    displaced: Transition {
        SmoothedAnimation { property: "y"; duration: 300 }
        NumberAnimation { property: "opacity"; to:1; duration: 1 }
    }
    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to:1; duration: 200 }
    }
    remove: Transition {
        NumberAnimation { property: "opacity"; from: 1; to:0; duration: 200 }
    }
}
