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

    function send () {
        if ( sending || messageTextField.displayText === "" ) return


        // Send the message
        var messageID = "%" + new Date().getTime();
        var now = new Date().getTime()
        var data = {
            msgtype: "m.text",
            body: messageTextField.displayText
        }

        // Save the message in the database
        storage.query ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [ messageID,
        activeChat,
        now,
        matrix.matrixid,
        messageTextField.displayText,
        null,
        "m.room.message",
        JSON.stringify(data),
        msg_status.SENDING ], function ( rs ) {
            // Send the message
            var fakeEvent = {
                type: "m.room.message",
                id: messageID,
                sender: matrix.matrixid,
                content_body: messageTextField.displayText,
                displayname: settings.displayname,
                avatar_url: settings.avatar_url,
                status: msg_status.SENDING,
                origin_server_ts: now,
                content: {}
            }
            chatScrollView.addEventToList ( fakeEvent )

            matrix.sendMessage ( messageID, data, activeChat, function ( response ) {
                chatScrollView.messageSent ( messageID, response )
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
            console.log(eventContent.user)
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
        visible: settings.chatBackground === undefined || backgroundImage.status !== Image.ready
        anchors.fill: parent
        opacity: 0.1
        color: settings.mainColor
        z: 0
    }

    Icon {
        visible: settings.chatBackground === undefined || backgroundImage.status !== Image.ready
        source: "../../assets/chat.svg"
        anchors.centerIn: parent
        width: parent.width / 1.25
        height: width
        opacity: 0.15
        z: 0
    }

    Image {
        id: backgroundImage
        visible: settings.chatBackground !== undefined
        anchors.fill: parent
        source: settings.chatBackground !== undefined ? settings.chatBackground : ""
        cache: true
        fillMode: Image.PreserveAspectCrop
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
        color: "white"
        z: 14
        Icon {
            name: "toolkit_chevron-down_1gu"
            width: units.gu(2.5)
            height: width
            anchors.centerIn: parent
            z: 14
        }
        visible: !chatScrollView.atYEnd
    }

    ChatScrollView {
        id: chatScrollView
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

        WebView {
            id: uploader
            url: "../components/upload.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&activeChat=" + encodeURIComponent(activeChat)
            width: chatInputActionBar.width + units.gu(1)
            height: width
            anchors.verticalCenter: parent.verticalCenter
            preferences.allowFileAccessFromFileUrls: true
            preferences.allowUniversalAccessFromFileUrls: true
            filePicker: pickerComponent
            visible: membership === "join" && canSendMessages
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
            onActiveFocusChanged: if ( !activeFocus ) sendTypingNotification ( activeFocus )
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
