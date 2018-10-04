import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Web 0.2
import "../components"

Page {

    id: chatPage

    property var sending: false
    property var membership: "join"
    property var isTyping: false
    property var pageName: "chat"
    property var canSendMessages: true
    property var chatMembers: chatScrollView.chatMembers

    function send ( sticker ) {
        console.log(JSON.stringify(sticker))
        if ( (sending || messageTextField.displayText === "") && sticker === undefined ) return


        // Send the message
        var now = new Date().getTime()
        var messageID = "" + now
        var data = {
            msgtype: "m.text",
            body: messageTextField.displayText
        }
        var urlRegex = /(https?:\/\/[^\s]+)/g
        var content_body = messageTextField.displayText || ""
        if ( content_body === "" ) content_body = " "
        content_body = content_body.replace(urlRegex, function(url) {
            return '<a href="%1">%1</a>'.arg(url)
        })

        if ( sticker ) {
            data.body = sticker.name
            data.msgtype = "m.sticker"
            data.url = sticker.url
            data.info = {
                "mimetype": sticker.mimetype,
                "thumbnail_url": sticker.thumbnail_url || sticker.url,
            }
            console.log(JSON.stringify(data))
        }

        // Save the message in the database
        storage.query ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [ messageID,
        activeChat,
        now,
        matrix.matrixid,
        messageTextField.displayText,
        null,
        data.msgtype,
        JSON.stringify(data),
        msg_status.SENDING ], function ( rs ) {
            // Send the message
            var fakeEvent = {
                type: data.msgtype,
                id: messageID,
                sender: matrix.matrixid,
                content_body: content_body,
                displayname: chatMembers[matrix.matrixid].displayname,
                avatar_url: chatMembers[matrix.matrixid].avatar_url,
                status: msg_status.SENDING,
                origin_server_ts: now,
                content: {}
            }
            chatScrollView.addEventToList ( fakeEvent )

            matrix.sendMessage ( messageID, data, activeChat, function ( response ) {
                chatScrollView.messageSent ( messageID, response )
            }, function () {
                chatScrollView.removeEvent ( messageID )
            } )

            isTyping = true
            messageTextField.focus = false
            messageTextField.text = ""
            messageTextField.focus = true
            isTyping = false
            sendTypingNotification ( false )
        })
    }


    function sendTypingNotification ( typing ) {
        if ( !settings.sendTypingNotification ) return
        if ( !typing && isTyping) {
            typingTimer.stop ()
            isTyping = false
            matrix.put ( "/client/r0/rooms/%1/typing/%2".arg( activeChat ).arg( matrix.matrixid ), {
                typing: false
            } )
        }
        else if ( typing && !isTyping ) {
            isTyping = true
            typingTimer.start ()
            matrix.put ( "/client/r0/rooms/%1/typing/%2".arg( activeChat ).arg( matrix.matrixid ), {
                typing: true,
                timeout: typingTimeout
            } )
        }
    }


    Component.onCompleted: {
        backgroundImage.opacity = 1
        storage.transaction ( "SELECT draft, membership, unread, power_events_default, power_redact FROM Chats WHERE id='" + activeChat + "'", function (res) {
            if ( res.rows.length === 0 ) return
            membership = res.rows[0].membership
            if ( res.rows[0].draft !== "" && res.rows[0].draft !== null ) messageTextField.text = res.rows[0].draft
            chatScrollView.unread = res.rows[0].unread
            storage.transaction ( "SELECT power_level FROM Memberships WHERE " +
            "matrix_id='" + matrix.matrixid + "' AND chat_id='" + activeChat + "'", function ( rs ) {
                chatScrollView.canRedact = rs.rows[0].power_level >= res.rows[0].power_redact
                canSendMessages = rs.rows[0].power_level >= res.rows[0].power_events_default
            })
        })
        chatScrollView.init ()
        chatActive = true
    }

    Component.onDestruction: {
        backgroundImage.opacity = 0
        var lastEventId = chatScrollView.count > 0 ? chatScrollView.lastEventId : ""
        storage.query ( "UPDATE Chats SET draft=?, unread=? WHERE id=?", [
        messageTextField.displayText,
        lastEventId,
        activeChat
        ])
        sendTypingNotification ( false )
        chatActive = false
        audio.stop ()
        audio.source = ""
    }

    Connections {
        target: events
        onNewChatUpdate: newChatUpdate ( chat_id, membership, notification_count, highlight_count, limitedTimeline )
        onNewEvent: newEvent ( type, chat_id, eventType, eventContent )
    }

    function newChatUpdate ( chat_id, new_membership, notification_count, highlight_count, limitedTimeline ) {
        if ( chat_id !== activeChat ) return
        membership = new_membership
        if ( limitedTimeline ) chatScrollView.model.clear ()
    }

    function newEvent ( type, chat_id, eventType, eventContent ) {
        if ( chat_id !== activeChat ) return
        if ( type === "m.typing" ) {
            activeChatTypingUsers = eventContent
        }
        else if ( type === "m.room.member") {
            chatScrollView.chatMembers [eventContent.state_key] = eventContent.content
        }
        else if ( type === "m.receipt" ) {
            chatScrollView.markRead ( eventContent.ts )
        }
        if ( eventType === "timeline" ) {
            chatScrollView.handleNewEvent ( type, eventContent )
            matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + eventContent.event_id, null )
        }
    }

    ChangeChatnameDialog { id: changeChatnameDialog }

    header: FcPageHeader {
        id: header
        title: (activeChatDisplayName || i18n.tr("Unknown chat")) + (activeChatTypingUsers.length > 0 ? "\n" + usernames.getTypingDisplayString( activeChatTypingUsers, activeChatDisplayName ) : "")

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "edit-delete"
                text: i18n.tr("Remove")
                visible: membership !== "join"
                onTriggered: PopupUtils.open ( leaveChatDialog )
            },
            Action {
                iconName: "info"
                text: i18n.tr("Chat info")
                visible: membership === "join"
                onTriggered: mainStack.push(Qt.resolvedUrl("./ChatSettingsPage.qml"))
            },
            Action {
                iconName: "notification"
                text: i18n.tr("Notifications")
                visible: membership === "join"
                onTriggered: mainStack.push(Qt.resolvedUrl("./NotificationChatSettingsPage.qml"))
            },
            Action {
                iconName: "contact-new"
                text: i18n.tr("Invite a friend")
                visible: membership === "join"
                onTriggered: mainStack.push(Qt.resolvedUrl("./InvitePage.qml"))
            }
            ]
        }
    }

    LeaveChatDialog { id: leaveChatDialog }

    Rectangle {
        visible: settings.chatBackground === undefined
        anchors.fill: parent
        opacity: 0.1
        color: settings.mainColor
        z: 0
    }

    Icon {
        visible: settings.chatBackground === undefined
        source: "../../assets/chat.svg"
        anchors.centerIn: parent
        width: parent.width / 1.25
        height: width
        opacity: 0.15
        z: 0
    }


    Label {
        text: i18n.tr('No messages in this chat ...')
        anchors.centerIn: parent
        visible: chatScrollView.count === 0
    }


    MouseArea {
        width: scrollDownButton.width
        height: scrollDownButton.height
        onClicked: chatScrollView.positionViewAtBeginning ()
        anchors.fill: scrollDownButton
        z: 15
        visible: scrollDownButton.visible
    }
    Rectangle {
        id: scrollDownButton
        width: parent.width
        anchors.bottom: chatInput.top
        anchors.left: parent.left
        height: header.height - 2
        opacity: 0.9
        color: theme.palette.normal.background
        z: 14
        Icon {
            name: "toolkit_chevron-down_4gu"
            width: units.gu(2.5)
            height: width
            anchors.centerIn: parent
            z: 14
            color: mainFontColor
        }
        visible: !chatScrollView.atYEnd
    }

    ChatScrollView {
        id: chatScrollView
    }

    Rectangle {
        id: stickerInput
        visible: false
        width: parent.width + 2
        property var desiredHeight: 3 * header.height
        height: desiredHeight
        border.width: 1
        border.color: UbuntuColors.silk
        color: theme.palette.normal.background
        anchors.bottom: chatInput.top
        anchors.horizontalCenter: parent.horizontalCenter

        ActionSelectionPopover {
            id: deleteActions
            property var contextElem
            z: 10
            actions: ActionList {
                Action {
                    text: i18n.tr("Delete sticker")
                    onTriggered: {
                        var url = deleteActions.contextElem.url
                        storage.transaction ( "DELETE FROM Media WHERE url='" + url + "'")
                        for ( var i = 0; i < stickerModel.count; i++ ) {
                            if ( stickerModel.get(i).mediaElem.url === url ) {
                                stickerModel.remove(i)
                                break
                            }
                        }
                    }
                }
            }
        }

        function show() {
            messageTextField.focus = false
            visible = true
            storage.transaction ("SELECT * FROM Media", function ( res ) {
                stickerModel.clear()
                for ( var i = res.rows.length-1; i >= 0; i-- ) {
                    stickerModel.append( { mediaElem: res.rows[i] } )
                }
            })
        }

        function hide() { visible = false }

        ListView {
            id: grid
            anchors.fill: parent
            orientation: ListView.Horizontal
            delegate: Rectangle {
                id: delegate
                width: grid.height
                height: grid.height
                AnimatedImage {
                    id: image
                    anchors.fill: delegate
                    width: height * ( sourceSize.height / sourceSize.width )
                    height: desiredHeight
                    property var mediaElement: mediaElem
                    source: {
                        ( (settings.autoloadGifs && mediaElem.mimetype === "image/gif") || mediaElem.thumbnail_url === "") ?
                        media.getLinkFromMxc ( mediaElem.url ) :
                        media.getThumbnailLinkFromMxc ( mediaElem.thumbnail_url, Math.round (height), Math.round (height) )
                    }
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: image
                    onClicked: {
                        stickerInput.hide ()
                        send ( image.mediaElement )
                    }
                    onPressAndHold: {
                        deleteActions.contextElem = image.mediaElement
                        deleteActions.show()
                    }
                }
            }
            header: WebView {
                id: uploader
                url: "../components/upload.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&activeChat=" + encodeURIComponent(activeChat)
                width: stickerInput.desiredHeight / 2
                height: width
                anchors.margins: stickerInput.desiredHeight / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                preferences.allowFileAccessFromFileUrls: true
                preferences.allowUniversalAccessFromFileUrls: true
                filePicker: pickerComponent
                visible: stickerInput.visible
                alertDialog: Dialog {
                    title: i18n.tr("Error")
                    text: model.message
                    parent: QuickUtils.rootItem(this)
                    Button {
                        text: i18n.tr("OK")
                        onClicked: model.accept()
                    }
                    Component.onCompleted: show()
                }
            }
            model: ListModel { id: stickerModel }
        }
    }

    Rectangle {
        id: chatInput
        height: header.height
        width: parent.width + 2
        border.width: 1
        border.color: UbuntuColors.silk
        color: theme.palette.normal.background
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: -border.width
            leftMargin: -border.width
            rightMargin: -border.width
        }


        Button {
            id: joinButton
            color: UbuntuColors.green
            text: membership === "invite" ? i18n.tr("Accept invitation") : i18n.tr("Join")
            anchors.centerIn: parent
            visible: membership !== "join"
            onClicked: {
                loadingScreen.visible = true
                matrix.post("/client/r0/join/" + encodeURIComponent(activeChat), null, function () {
                    events.waitForSync ()
                    membership = "join"
                })
            }
        }


        Label {
            text: i18n.tr("You are not allowed to send messages")
            anchors.centerIn: parent
            visible: !canSendMessages
        }

        Component {
            id: pickerComponent
            PickerDialog {}
        }


        Timer {
            id: typingTimer
            interval: typingTimeout
            running: false
            repeat: false
            onTriggered: isTyping = false
        }

        TextField {
            id: messageTextField
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: units.gu(1)
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 2 * chatInputActionBar.width - units.gu(2)
            placeholderText: i18n.tr("Type something ...")
            Keys.onReturnPressed: sendButton.trigger ()
            // If the user leaves the focus of the textfield: Send that he is no
            // longer typing.
            onActiveFocusChanged: {
                if ( activeFocus && stickerInput.visible ) stickerInput.hide()
                if ( !activeFocus ) sendTypingNotification ( activeFocus )
            }
            onDisplayTextChanged: {
                // A message must not start with white space
                if ( displayText === " " ) text = ""
                else {
                    // Send typing notification true or false
                    if ( displayText !== "" ) {
                        sendTypingNotification ( true )
                    }
                    else {
                        sendTypingNotification ( false )
                    }
                }
            }
            visible: membership === "join" && canSendMessages
        }

        ActionBar {
            id: showStickerInput
            visible: membership === "join" && canSendMessages
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: units.gu(0.5)
            actions: [
            Action {
                iconName: stickerInput.visible ? "close" : "add"
                onTriggered: stickerInput.visible ? stickerInput.hide() : stickerInput.show()
                enabled: !sending
            }
            ]
        }

        ActionBar {
            id: chatInputActionBar
            visible: membership === "join" && canSendMessages
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: units.gu(0.5)
            actions: [
            Action {
                id: sendButton
                iconName: "send"
                onTriggered: send ()
                enabled: !sending
            }
            ]
        }
    }

}
