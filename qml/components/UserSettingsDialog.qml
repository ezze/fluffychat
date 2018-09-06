import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: userSettings

    Dialog {
        id: dialogue
        title: usernames.getById ( activeUser )

        Component.onCompleted: {
            startNewChatButton.enabled = true
            storage.transaction ( "SELECT avatar_url FROM Users WHERE matrix_id='" + activeUser + "'", function ( res ) {
                if ( res.rows.length === 1 ) avatar.mxc = res.rows[0].avatar_url
            })

            storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url " +
            " FROM Chats rooms, Memberships memberships " +
            " WHERE rooms.membership!='leave' " +
            " AND memberships.matrix_id='" + activeUser + "' " +
            " AND memberships.chat_id=rooms.id " +
            " ORDER BY rooms.topic "
            , function(res) {
                // We now write the rooms in the column
                for ( var i = 0; i < res.rows.length; i++ ) {
                    var room = res.rows.item(i)
                    // We request the room name, before we continue
                    model.append ( { "room": room } )
                }
            })
        }

        Avatar {
            id: avatar
            width: parent.width
            name: dialogue.title
        }

        Button {
            id: startNewChatButton
            text: i18n.tr("Start new Chat")
            color: settings.mainColor
            iconName: "message-new"
            onClicked: {
                var data = {
                    "invite": [ activeUser ],
                    "is_direct": true,
                    "preset": "private_chat"
                }
                matrix.post( "/client/r0/createRoom", data, function ( res ) {
                    startNewChatButton.enabled = false
                    PopupUtils.close(dialogue)
                    mainStack.toStart ()
                    activeChat = res.room_id
                    activeChatTypingUsers = []
                    mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
                    if ( room.notification_count > 0 ) matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + room.eventsid, null )
                } )
            }
        }

        Button {
            text: i18n.tr("Ignore")
            color: settings.mainColor
            iconName: "security-alert"
            onClicked: {
                PopupUtils.close(dialogue)
            }
        }

        Button {
            id: button
            text: i18n.tr("Close")
            color: settings.mainColor
            iconName: "close"
            onClicked: PopupUtils.close(dialogue)
        }

        Rectangle {
            width: parent.width
            height: units.gu(5)
            color: settings.darkmode ? UbuntuColors.inkstone : theme.palette.normal.background
            Label {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: units.gu(1.5)
                text: i18n.tr("Chats with %1:").arg(dialogue.title)
                width: parent.width
                wrapMode: Text.Wrap
                font.bold: true
            }
        }

        ListView {
            id: chatListView
            width: parent.width
            height: units.gu(13)
            delegate: SimpleChatListItem {}
            model: ListModel { id: model }
            z: -1
        }

    }

}
