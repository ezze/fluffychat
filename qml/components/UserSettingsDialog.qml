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
            text: i18n.tr("Start new Chat")
            color: settings.mainColor
            iconName: "message-new"
            onClicked: {
                PopupUtils.close(dialogue)
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
            text: i18n.tr("Close")
            color: settings.mainColor
            iconName: "close"
            onClicked: PopupUtils.close(dialogue)
        }

        Label {
            text: i18n.tr("Chats with %1:").arg(dialogue.title)
            width: parent.width
            wrapMode: Text.Wrap
            font.bold: true
        }

        ListView {
            id: chatListView
            width: parent.width
            height: units.gu(16)
            delegate: SimpleChatListItem {}
            model: ListModel { id: model }
        }

    }

}
