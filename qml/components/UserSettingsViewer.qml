import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../scripts/MatrixNames.js" as MatrixNames

BottomEdge {

    id: userSettingsViewer
    height: parent.height

    onCollapseCompleted: userSettingsViewer.destroy ()
    Component.onCompleted: commit()

    contentComponent: Page {
        id: userSettingsPage
        property var matrix_id: ""
        property var displayname: ""
        height: userSettingsViewer.height
        Rectangle {
            id: background
            anchors.fill: parent
            color: theme.palette.normal.background
        }

        PageHeader {
            id: userHeader
            title: displayname

            trailingActionBar {
                actions: [
                Action {
                    iconName: "mail-forward"
                    onTriggered: contentHub.shareTextIntern ( matrix_id )
                },
                Action {
                    iconName: "edit-copy"
                    onTriggered: {
                        contentHub.toClipboard ( matrix_id )
                        toast.show( i18n.tr("Username has been copied to the clipboard") )
                    }
                }
                ]
            }
        }

        Component.onCompleted:  {
            matrix_id = activeUser
            displayname = MatrixNames.transformFromId ( matrix_id )

            storage.transaction ( "SELECT displayname, avatar_url, presence, last_active_ago, currently_active FROM Users WHERE matrix_id='" + matrix_id + "'", function ( res ) {
                if ( res.rows.length === 1 ) profileRow.avatar_url = res.rows[0].avatar_url
                if ( res.rows[0].displayname !== "" && res.rows[0].displayname !== null ) {
                    displayname = res.rows[0].displayname
                }
                profileRow.presence = res.rows[0].presence
                profileRow.last_active_ago = res.rows[0].last_active_ago
                profileRow.currently_active = res.rows[0].currently_active
            })

            if ( matrix_id === matrix.matrixid ) return
            storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url " +
            " FROM Chats rooms, Memberships memberships " +
            " WHERE (memberships.membership='join' OR memberships.membership='invite') " +
            " AND memberships.matrix_id='" + matrix_id + "' " +
            " AND memberships.chat_id=rooms.id " +
            " ORDER BY rooms.topic "
            , function(res) {
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
            })
        }


        ScrollView {
            id: scrollView
            width: parent.width
            height: userSettingsViewer.height - userHeader.height
            anchors.top: userHeader.bottom
            contentItem: Column {
                width: userSettingsViewer.width

                Rectangle {
                    width: parent.width
                    height: units.gu(2)
                    color: "#00000000"
                }

                ProfileRow {
                    id: profileRow
                    matrixid: activeUser
                    displayname: userSettingsPage.displayname
                }

                Rectangle {
                    width: parent.width
                    height: units.gu(2)
                    color: "transparent"
                }

                ListSeperator {
                    text: matrix_id !== matrix.matrixid ? i18n.tr("Chats with this user:") : i18n.tr("You are that!")
                }

                Column {
                    id: chatListView
                    width: parent.width
                    visible: matrix_id !== matrix.matrixid
                }

                ListItem {
                    id: startNewChatButton
                    height: layout.height
                    color: Qt.rgba(0,0,0,0)
                    visible: matrix_id !== matrix.matrixid
                    onClicked: {
                        userSettingsViewer.collapse ()
                        var data = {
                            "invite": [ matrix_id ],
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

            }
        }


    }
}
