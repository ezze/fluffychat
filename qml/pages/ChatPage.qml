import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {

    id: chatPage

    property var sending: false
    property var membership: "join"

    function send () {
        if ( sending || messageTextField.displayText === "" ) return
        var messageID = Math.floor((Math.random() * 1000000) + 1);
        var data = {
            msgtype: "m.text",
            body: messageTextField.displayText
        }
        var fakeEvent = {
            type: "m.room.message",
            sender: matrix.matrixid,
            content_body: messageTextField.displayText,
            displayname: settings.displayname,
            avatar_url: settings.avatar_url,
            sending: true,
            origin_server_ts: new Date().getTime(),
            content: {}
        }
        chatScrollView.addEventToList ( fakeEvent )

        var error_callback = function ( error ) {
            if ( error.error !== "offline" ) toast.show ( error.errcode + ": " + error.error )
            chatScrollView.update ()
        }

        matrix.put( "/client/r0/rooms/" + activeChat + "/send/m.room.message/" + messageID, data, null, error_callback )

        messageTextField.focus = false
        messageTextField.text = ""
        messageTextField.focus = true
    }


    function sendAttachement ( mediaUrl ) {

        // Start the upload
        matrix.upload ( mediaUrl, function ( response ) {
            // Uploading was successfull, send now the file event
            console.log( JSON.stringify(response) )
            var messageID = Math.floor((Math.random() * 1000000) + 1);
            var data = {
                msgtype: "m.image",
                body: "Image",
                url: response.content_uri
            }
            var error_callback = function ( error ) {
                if ( error.error !== "offline" ) toast.show ( error.errcode + ": " + error.error )
                chatScrollView.update ()
            }

            matrix.put( "/client/r0/rooms/" + activeChat + "/send/m.room.message/" + messageID, data, null, error_callback )
        }, console.error )

        // Set the fake event while the file is uploading
        var fakeEvent = {
            type: "m.room.message",
            sender: matrix.matrixid,
            content_body: "Datei wird gesendet ...",
            displayname: matrix.displayname,
            avatar_url: matrix.avatar_url,
            sending: true,
            origin_server_ts: new Date().getTime(),
            content: {}
        }
        chatScrollView.addEventToList ( fakeEvent )
        messageTextField.focus = false
        messageTextField.text = ""
        messageTextField.focus = true
    }


    MediaImport { id: mediaImport }


    Component.onCompleted: {
        storage.transaction ( "SELECT membership FROM Rooms WHERE id='" + activeChat + "'", function (res) {
            membership = res.rows.length > 0 ? res.rows[0].membership : "join"
        })
        chatScrollView.update ()
    }

    Component.onDestruction: {
        activeChat = activeChatDisplayName = null
    }

    Connections {
        target: events
        onChatTimelineEvent: chatScrollView.handleNewEvent ( response )
    }

    Connections {
        target: mediaImport
        onMediaReceived: sendAttachement ( mediaUrl )
    }


    InviteDialog { id: inviteDialog }

    ChangeChatnameDialog { id: changeChatnameDialog }

    header: FcPageHeader {
        id: header
        title: activeChatDisplayName || i18n.tr("Unknown chat")

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "info"
                text: i18n.tr("Chat info")
                onTriggered: mainStack.push(Qt.resolvedUrl("./ChatSettingsPage.qml"))
            },
            Action {
                iconName: "notification"
                text: i18n.tr("Notifications")
                onTriggered: mainStack.push(Qt.resolvedUrl("./NotificationChatSettingsPage.qml"))
            },
            Action {
                iconName: "contact-new"
                text: i18n.tr("Invite a friend")
                onTriggered: PopupUtils.open(inviteDialog)
            }
            ]
        }
    }

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

    Image {
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
        anchors.bottom: chatInput.top
        anchors.right: parent.right
        anchors.margins: units.gu(2)
        z: 10
        Rectangle {
            id: scrollDownButton
            width: units.gu(6)
            height: width
            opacity: 0.75
            color: "#000000"
            radius: units.gu(2)
            Icon {
                name: "toolkit_chevron-down_1gu"
                width: parent.width * 0.75
                height: parent.height * 0.75
                anchors.centerIn: parent
                color: "#FFFFFF"
            }
            visible: !chatScrollView.atYEnd
        }
    }

    ChatScrollView { id: chatScrollView }

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
            text: i18n.tr("Accept invatiation")
            anchors.centerIn: parent
            visible: membership === "invite"
            onClicked: {
                var success_callback = function () {
                    toast.show ( i18n.tr("Synchronizing \n This can take a few minutes ...") )
                    events.waitForSync ()
                    membership = "join"
                }
                matrix.post("/client/r0/join/" + encodeURIComponent(activeChat), null, success_callback)
            }
        }

        /*ActionBar {
            id: chatAttachementActionBar
            visible: membership === "join"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: units.gu(0.5)
            actions: [
            Action {
                id: attachementButton
                iconName: "camera-photo-symbolic"
                onTriggered: mediaImport.requestMedia ()
                enabled: !sending
            }
            ]
        }*/

        TextField {
            id: messageTextField
            anchors.bottom: parent.bottom
            //anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: units.gu(1)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - chatInputActionBar.width - units.gu(2) /*- chatAttachementActionBar.width */
            placeholderText: i18n.tr("Type something ...")
            Keys.onReturnPressed: sendButton.trigger ()
            visible: membership === "join"
        }
        ActionBar {
            id: chatInputActionBar
            visible: membership === "join"
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
