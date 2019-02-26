import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/MatrixNames.js" as MatrixNames

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: activeUser

        property var presence: "offline"
        property var last_active_ago: 0
        property var currently_active: false

        Rectangle {
            height: onlineLabel.height
            width: parent.width
            Label {
                id: onlineLabel
                text: currently_active === true ? i18n.tr("Currently active") :
                ( last_active_ago !== 0 ? i18n.tr("Last seen: %1").arg( MatrixNames.getChatTime ( last_active_ago ) ) : presence)
                wrapMode: Text.Wrap
                font.bold: true
                color: "#888888"
                anchors.centerIn: parent
            }
        }


        Avatar {  // Useravatar
            id: avatarImage
            name: activeUser
            width: parent.width
            height: width
            onClickFunction: function () {
                imageViewer.show ( mxc )
            }
        }

        Row {

            Column {
                width: parent.width - actionBar.width
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    id: fullUsernameLabel
                    text: i18n.tr("Full username:")
                    width: parent.width
                    textSize: Label.Small
                    font.bold: true
                }
                Label {
                    text: activeUser
                    width: parent.width
                    textSize: Label.Small
                }
            }


            ActionBar {
                id: actionBar
                actions: [
                Action {
                    iconName: "mail-forward"
                    onTriggered: contentHub.shareTextIntern ( activeUser )
                },
                Action {
                    iconName: "edit-copy"
                    onTriggered: {
                        contentHub.toClipboard ( activeUser )
                        toast.show( i18n.tr("Username has been copied to the clipboard") )
                    }
                }
                ]
            }
        }

        Button {
            text: i18n.tr("Close")
            color: mainLayout.mainColor
            onClicked: PopupUtils.close(dialogue)
        }

        Rectangle {
            color: "transparent"
            height: orLabel.height
            width: parent.width

            Rectangle {
                height: units.gu(0.2)
                color: mainLayout.mainColor
                anchors.left: parent.left
                anchors.right: orLabel.left
                anchors.rightMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
            }
            Label {
                id: orLabel
                text: activeUser !== matrix.matrixid ? i18n.tr("Chats with this user:") : i18n.tr("You are that!")
                textSize: Label.Small
                anchors.centerIn: parent
            }
            Rectangle {
                height: units.gu(0.2)
                color: mainLayout.mainColor
                anchors.right: parent.right
                anchors.left: orLabel.right
                anchors.leftMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Column {
            id: chatListView
            width: parent.width
            visible: activeUser !== matrix.matrixid
        }

        ListItem {
            id: startNewChatButton
            height: layout.height
            color: Qt.rgba(0,0,0,0)
            visible: activeUser !== matrix.matrixid
            onClicked: {
                userSettingsViewer.collapse ()
                var data = {
                    "invite": [ activeUser ],
                    "is_direct": true,
                    "preset": "trusted_private_chat"
                }
                var _toast = toast
                matrix.post( "/client/r0/createRoom", data, function (res) {
                    if ( res.room_id ) _mainLayout.toChat ( res.room_id )
                    _toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
                }, null, 2 )
            }

            ListItemLayout {
                id: layout
                title.text: i18n.tr("Start new chat")
                Icon {
                    name: "message-new"
                    width: units.gu(4)
                    height: units.gu(4)
                    SlotsLayout.position: SlotsLayout.Leading
                }
            }
        }


        Component.onCompleted:  {
            title = MatrixNames.transformFromId ( activeUser )

            var res = storage.query ( "SELECT displayname, avatar_url, presence, last_active_ago, currently_active FROM Users WHERE matrix_id=?", [ activeUser ] )
            if ( res.rows.length === 1 ) avatarImage.mxc = res.rows[0].avatar_url
            if ( res.rows[0].displayname !== "" && res.rows[0].displayname !== null ) {
                title = res.rows[0].displayname
            }
            presence = res.rows[0].presence
            last_active_ago = res.rows[0].last_active_ago
            currently_active = res.rows[0].currently_active

            if ( activeUser === matrix.matrixid ) return
            res = storage.query ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url " +
            " FROM Chats rooms, Memberships memberships " +
            " WHERE (memberships.membership='join' OR memberships.membership='invite') " +
            " AND memberships.matrix_id=? " +
            " AND memberships.chat_id=rooms.id " +
            " ORDER BY rooms.topic "
            , [ activeUser ] )
            chatListView.children = ""
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                // We request the room name, before we continue
                var item = Qt.createComponent("../components/SimpleChatListItem.qml")
                item.createObject(chatListView, {
                    "room": room
                })
            }
        }
    }
}
