import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import E2ee 1.0
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/MessageFormats.js" as MessageFormats
import "../scripts/ChatPageActions.js" as ChatPageActions

Page {

    id: chatPage

    readonly property var typingTimeout: 30000

    property var membership: "join"
    property var isTyping: false
    property var pageName: "chat"
    property var canSendMessages: true
    property var canRedact: false
    property var replyEvent: null
    property var chat_id
    property var topic: ""
    property var historyCount: 20
    property var requesting: false
    property var initialized: -1
    property var count: chatScrollView.count
    property alias model: chatScrollView.model

    anchors.fill: parent

    signal load ()
    onLoad: ChatPageActions.init ()

    signal send ( var message )
    onSend: ChatPageActions.send ( message )

    signal removeEvent ( var id )
    onRemoveEvent: ChatPageActions.removeEvent ( id )

    Connections {
        target: matrix
        onNewChatUpdate: ChatPageActions.newChatUpdate ( chat_id, membership, notification_count, highlight_count, limitedTimeline )
        onNewEvent: ChatPageActions.newEvent ( type, chat_id, eventType, eventContent )
    }


    ChangeChatnameDialog { id: changeChatnameDialog }

    header: PageHeader {
        id: header
        title: (activeChatDisplayName || i18n.tr("Unknown chat"))

        contents: Rectangle {
            anchors.fill: parent
            color: "transparent"
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    id: titleLabel
                    text: header.title
                    color: mainLayout.mainFontColor
                    textSize: Label.Large
                    width: parent.width
                    Transition {
                        NumberAnimation { properties: "anchors.topMargin"; duration: 1000 }
                    }
                }

                Label {
                    id: typingLabel
                    visible: activeChatTypingUsers.length > 0
                    height: visible ? units.gu(2) : 0
                    text: (activeChatTypingUsers.length > 0 ? MatrixNames.getTypingDisplayString( activeChatTypingUsers, activeChatDisplayName ) : "")
                    color: mainLayout.mainFontColor
                }
            }
        }

        leadingActionBar {
            actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    ChatPageActions.destruction ()
                    mainLayout.removePages( mainLayout.primaryPage )
                }
            }
            ]
        }

        trailingActionBar {
            id: trailingBar
        }

    }

    states: [
    State {
        id: defaultState
        name: "default"
        when: membership === "join"
        property list<QtObject> trailingActions: [
        Action {
            id: showSettingsPage
            iconName: "contextual-menu"
            text: i18n.tr("Chat info")
            onTriggered: bottomEdgePageStack.push (Qt.resolvedUrl("./ChatSettingsPage.qml") )
        }
        ]
        PropertyChanges {
            target: trailingBar
            actions: defaultState.trailingActions
        }
    }
    ]

    Icon {
        property var resolution: ( 1052 / 744 )
        visible: mainLayout.chatBackground === undefined
        source: "../../assets/chat.svg"
        color: mainLayout.mainColor
        anchors.centerIn: parent
        width: Math.min ( parent.width, parent.height / resolution  )
        height: width * resolution
        opacity: 0.1
        z: 0
    }


    Label {
        text: i18n.tr('No messages in this chat ...')
        anchors.centerIn: parent
        visible: count === 0
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
            text: replyEvent !== null ? i18n.tr("Reply to <b>%1</b>: \"%2\"").arg(activeChatMembers[replyEvent.sender].displayname).arg(replyEvent.content.body.split("\n").join(" ")) : ""
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



    FlyingButton {
        id: scrollDownButton
        onClicked: chatScrollView.positionViewAtBeginning ()
        iconName: "toolkit_chevron-down_4gu"
        anchors.bottomMargin: (width/2) + chatInput.height
        visibleState: !chatScrollView.atYEnd
    }

    ChatScrollView {
        id: chatScrollView
        anchors.top: header.bottom
        anchors.bottom: chatInput.top
        onContentYChanged: if ( atYBeginning ) ChatPageActions.requestHistory ()
    }

    StickerInput {
        id: stickerInput
        anchors.bottom: chatInput.top
    }

    Rectangle {
        width: parent.width
        height: 1
        anchors.bottom:chatInput.top
        color: mainDividerColor
    }

    Rectangle {
        id: chatInput
        height: messageTextField.height + units.gu(2)
        width: parent.width + 2
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
            onClicked: ChatPageActions.join ()
        }


        Label {
            text: i18n.tr("You do not have posting permissions here")
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
                verticalCenter: parent.verticalCenter
                right: chatInputActionBar.left
                left: showStickerInput.visible ? showStickerInput.right : parent.left
                margins: units.gu(1)
            }
            property var hasText: false
            autoSize: true
            placeholderText: i18n.tr("Type something ...")
            Keys.onReturnPressed: {
                var send = matrix.sendWithEnter
                if ( event.modifiers === Qt.ShiftModifier ) send = !send
                if ( send ) ChatPageActions.send ()
                else insert( cursorPosition, "\n")
            }
            // If the user leaves the focus of the textfield: Send that he is no
            // longer typing.
            onActiveFocusChanged: ChatPageActions.ActiveFocusChanged ( activeFocus )
            onDisplayTextChanged: ChatPageActions.sendTypingNotification ( displayText !== "" )
            visible: membership === "join" && canSendMessages && !stickerInput.visible
        }

        Button {
            id: showStickerInput
            iconName: stickerInput.visible ? "close" : "add"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.margins: units.gu(1)
            color: mainLayout.darkmode ? UbuntuColors.inkstone : UbuntuColors.porcelain
            visible: membership === "join" && canSendMessages && replyEvent === null
            width: height
            onClicked: stickerInput.visible ? stickerInput.hide() : stickerInput.show()
        }

        ActionBar {
            id: chatInputActionBar
            visible: membership === "join" && canSendMessages
            numberOfSlots: 6
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            delegate: Item {
                height: parent.height
                width: insideButton.height + units.gu(1)
                Button {
                    id: insideButton
                    action: modelData
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: height
                    color: mainLayout.darkmode ? UbuntuColors.inkstone : UbuntuColors.porcelain
                }
            }
            actions: [
            Action {
                id: sendButton
                iconName: "send"
                visible: platform === platforms.LINUX || (!stickerInput.visible && messageTextField.displayText !== "")
                onTriggered: ChatPageActions.send ()
            },
            Action {
                iconName: "camera-app-symbolic"
                visible: platform !== platforms.LINUX && (stickerInput.visible || messageTextField.displayText === "")
                onTriggered: ChatPageActions.sendFromCamera ()
            },
            Action {
                iconName: "stock_image"
                visible: platform !== platforms.LINUX && stickerInput.visible
                onTriggered: ChatPageActions.sendPicture ()
            },
            Action {
                iconName: "stock_video"
                visible: platform !== platforms.LINUX && stickerInput.visible
                onTriggered: ChatPageActions.sendVideo ()
            },
            Action {
                iconName: "preferences-desktop-sounds-symbolic"
                visible: platform !== platforms.LINUX && stickerInput.visible
                onTriggered: ChatPageActions.sendAudio ()
            },
            Action {
                iconName: "attachment"
                visible: platform !== platforms.LINUX && stickerInput.visible
                onTriggered: ChatPageActions.sendAll ()
            }
            ]
        }
    }

}
