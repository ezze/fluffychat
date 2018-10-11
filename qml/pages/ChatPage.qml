import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {

    id: chatPage

    property var membership: "join"
    property var isTyping: false
    property var pageName: "chat"
    property var canSendMessages: true
    property var chatMembers: chatScrollView.chatMembers
    property var replyEvent: null

    function send ( message ) {
        if ( messageTextField.displayText === "" && message === undefined ) return

        var sticker = undefined
        if ( message === undefined ) message = messageTextField.displayText
        if ( typeof message !== "string" ) sticker = message

        // Send the message
        var now = new Date().getTime()
        var messageID = "" + now
        var data = {
            msgtype: "m.text",
            body: message
        }

        if ( sticker !== undefined ) {
            data.body = sticker.name
            data.msgtype = "m.sticker"
            data.url = sticker.url
            data.info = {
                "mimetype": sticker.mimetype,
                "thumbnail_url": sticker.thumbnail_url || sticker.url,
            }
        }
        else {

            // Add reply event to message
            if ( replyEvent !== null ) {

                // Add event ID to the reply object
                data["m.relates_to"] = {
                    "m.in_reply_to": {
                        "event_id": replyEvent.id
                    }
                }

                // Use formatted body
                data.format = "org.matrix.custom.html"
                data.formatted_body = '<mx-reply><blockquote><a href="https://matrix.to/#/%1/%2">In reply to</a> <a href="https://matrix.to/#/%3">%4</a><br>%5</blockquote></mx-reply>'
                .arg(activeChat).arg(replyEvent.id).arg(replyEvent.sender).arg(replyEvent.sender).arg(replyEvent.content.body)
                + data.body

                // Change the normal body too
                var contentLines = replyEvent.content.body.split("\n")
                for ( var i = 0; i < contentLines.length; i++ ) {
                    if ( contentLines[i].slice(0,1) === ">" ) {
                        contentLines.splice(i,1)
                        i--
                    }
                }
                replyEvent.content.body = contentLines.join("\n")
                var replyBody = "> <%1> ".arg(replyEvent.sender) + replyEvent.content.body.split("\n").join("\n>")
                data.body = replyBody + "\n\n" + data.body

                replyEvent = null
            }

            data = sender.handleCommands ( data )

        }

        var type = sticker === undefined ? "m.room.message" : "m.sticker"

        // Save the message in the database
        storage.query ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [ messageID,
        activeChat,
        now,
        matrix.matrixid,
        message,
        null,
        type,
        JSON.stringify(data),
        msg_status.SENDING ], function ( rs ) {
            // Send the message
            var fakeEvent = {
                type: type,
                id: messageID,
                sender: matrix.matrixid,
                content_body: matrix.formatText ( data.body ),
                displayname: chatMembers[matrix.matrixid].displayname,
                avatar_url: chatMembers[matrix.matrixid].avatar_url,
                status: msg_status.SENDING,
                origin_server_ts: now,
                content: data
            }
            chatScrollView.addEventToList ( fakeEvent )

            sender.sendMessage ( messageID, data, activeChat, function ( response ) {
                chatScrollView.messageSent ( messageID, response )
            }, function ( error ) {
                if ( error === "DELETE" ) chatScrollView.removeEvent ( messageID )
                else chatScrollView.errorEvent ( messageID )
            } )

            if ( sticker === undefined && messageTextField.text !== "" ) {
                isTyping = true
                messageTextField.text = ""
                messageTextField.height = header.height - units.gu(2)
                isTyping = false
                sendTypingNotification ( false )
            }
        })
    }


    function sendTypingNotification ( typing ) {
        if ( !settings.sendTypingNotification ) return
        if ( !typing && isTyping) {
            typingTimer.stop ()
            isTyping = false
            matrix.put ( "/client/r0/rooms/%1/typing/%2".arg( activeChat ).arg( matrix.matrixid ), {
                typing: false
            }, null, null )
        }
        else if ( typing && !isTyping ) {
            isTyping = true
            typingTimer.start ()
            matrix.put ( "/client/r0/rooms/%1/typing/%2".arg( activeChat ).arg( matrix.matrixid ), {
                typing: true,
                timeout: typingTimeout
            }, null, null )
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

        // Is there something to share? Then now share it!
        if ( shareObject !== null ) {
            var message = ""
            for ( var i = 0; i < shareObject.items.length; i++ ) {
                if (String(shareObject.items[i].text).length > 0 && String(shareObject.items[i].url).length == 0) {
                    message += String(shareObject.items[i].text)
                }
                else if (String(shareObject.items[i].url).length > 0 ) {
                    message += String(shareObject.items[i].url)
                }
                if ( i+1 < shareObject.items.length ) message += "\n"
            }
            if ( message !== "") messageTextField.text = message
            shareObject = null
        }

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


    Rectangle {
        id: replyEventView
        width: parent.width
        anchors.bottom: chatInput.top
        anchors.left: parent.left
        height: header.height - 2
        opacity: 0
        color: theme.palette.normal.background
        z: 14
        Rectangle {
            width: parent.width
            height: 1
            color: UbuntuColors.silk
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
        Label {
            text: replyEvent !== null ? i18n.tr("Reply to <b>%1</b>: \"%2\"").arg(chatMembers[replyEvent.sender].displayname).arg(replyEvent.content.body.split("\n").join(" ")) : ""
            anchors.left: parent.left
            anchors.right: closeReplyIcon.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: units.gu(0.5)
            elide: Text.ElideRight
        }
        ActionBar {
            id: closeReplyIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: units.gu(0.5)
            actions: [
            Action {
                iconName: "close"
                onTriggered: replyEvent = null
            }
            ]
        }
        states: State {
            name: "visible"; when: replyEvent !== null
            PropertyChanges {
                target: replyEventView
                opacity: 1
            }
        }

        transitions: Transition {
            NumberAnimation { property: "opacity"; duration: 300 }
        }
    }



    Rectangle {
        id: scrollDownButton
        width: units.gu(8)
        height: width
        anchors.bottom: replyEvent === null ? chatInput.top : replyEventView.top
        anchors.right: parent.right
        anchors.margins: units.gu(2)
        border.width: 1
        border.color: UbuntuColors.slate
        radius: width / 6
        opacity: 0
        color: UbuntuColors.jet
        z: 14
        MouseArea {
            onClicked: chatScrollView.positionViewAtBeginning ()
            anchors.fill: parent
            visible: parent.opacity > 0
        }
        Icon {
            name: "toolkit_chevron-down_4gu"
            width: units.gu(2.5)
            height: width
            anchors.centerIn: parent
            z: 14
            color: "white"
        }
        states: State {
            name: "visible"; when: !chatScrollView.atYEnd
            PropertyChanges {
                target: scrollDownButton
                opacity: 0.9
            }
            PropertyChanges {
                target: stickerInput
                visible: false
            }
        }

        transitions: Transition {
            NumberAnimation { property: "opacity"; duration: 300 }
        }
    }

    ChatScrollView {
        id: chatScrollView
    }

    StickerInput {
        id: stickerInput
        anchors.bottom: chatInput.top
    }

    Rectangle {
        id: chatInput
        height: messageTextField.height + units.gu(2)
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

        TextArea {
            id: messageTextField
            anchors {
                bottom: parent.bottom
                margins: units.gu(1)
                rightMargin: units.gu(0.5)
                right: chatInputActionBar.left
                left: showStickerInput.visible ? showStickerInput.right : parent.left
            }
            property var hasText: false
            autoSize: height <= mainStackWidth / 2 - header.height - units.gu(2)
            maximumLineCount: 0
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

        Button {
            id: showStickerInput
            iconName: stickerInput.visible ? "close" : "add"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: units.gu(1)
            color: "#44" + settings.mainColor.replace("#","")
            visible: membership === "join" && canSendMessages && replyEvent === null
            width: height
            onClicked: stickerInput.visible ? stickerInput.hide() : stickerInput.show()
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
            }
            ]
        }
    }

}
