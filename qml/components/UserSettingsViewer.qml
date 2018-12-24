import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

BottomEdge {

    id: userSettingsViewer
    height: parent.height - parent.header.height

    onCollapseCompleted: userSettingsViewer.destroy ()
    Component.onCompleted: commit()

    contentComponent: Page {
            property var matrix_id: ""
            property var displayname: ""
            height: userSettingsViewer.height

            FcPageHeader {
                id: userHeader
                title: ""

                trailingActionBar {
                    actions: [
                    Action {
                        iconName: "mail-forward"
                        onTriggered: shareController.shareTextIntern ( matrix_id )
                    }
                    ]
                }
            }

            Component.onCompleted:  {
                matrix_id = activeUser
                userHeader.title = matrix_id

                storage.transaction ( "SELECT displayname, avatar_url, presence, last_active_ago, currently_active FROM Users WHERE matrix_id='" + matrix_id + "'", function ( res ) {
                    if ( res.rows.length === 1 ) avatar.mxc = res.rows[0].avatar_url
                    userHeader.title = res.rows[0].displayname
                    presenceListItem.presence = res.rows[0].presence
                    presenceListItem.last_active_ago = res.rows[0].last_active_ago
                    presenceListItem.currently_active = res.rows[0].currently_active
                })

                if ( matrix_id === matrix.matrixid ) return
                storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url " +
                " FROM Chats rooms, Memberships memberships " +
                " WHERE rooms.membership!='leave' " +
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

                    Avatar {  // Useravatar
                        id: avatar
                        width: parent.width
                        height: width * 10/16
                        name: activeUser
                        anchors.horizontalCenter: parent.horizontalCenter
                        mxc: ""
                        radius: 0
                        onClickFunction: function () {
                            if ( mxc !== "" ) {
                                userSettingsViewer.collapse ()
                                imageViewer.show ( mxc )
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: UbuntuColors.ash
                    }

                    UsernameListItem {
                        matrix_id: activeUser
                    }

                    ListItem {
                        id: presenceListItem
                        property var presence: "offline"
                        property var last_active_ago: 0
                        property var currently_active: false
                        height: statusListItemLayout.height
                        color: Qt.rgba(0,0,0,0)
                        ListItemLayout {
                            id: statusListItemLayout
                            title.text: i18n.tr("Status: %1 ").arg(presenceListItem.presence) + (presenceListItem.presence==="online" && presenceListItem.currently_active ? i18n.tr("and currently active") : "")
                            subtitle.text: presenceListItem.last_active_ago !== 0 ? i18n.tr("Last active: %1").arg( stamp.getChatTime ( presenceListItem.last_active_ago ) ) : ""

                            Icon {
                                name: presenceListItem.presence === "online" ? "sync-idle" :
                                    (presenceListItem.presence === "unavailable" ? "sync-paused" : "sync-offline")
                                    SlotsLayout.position: SlotsLayout.Leading
                                    width: units.gu(4)
                                    height: width
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: units.gu(2)
                        color: Qt.rgba(0,0,0,0)
                    }
                    Rectangle {
                        width: parent.width
                        height: units.gu(2)
                        color: Qt.rgba(0,0,0,0)
                        Label {
                            id: userInfo
                            height: units.gu(2)
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(2)
                            text: matrix_id !== matrix.matrixid ? i18n.tr("Chats with this user:") : i18n.tr("You are that!")
                            font.bold: true
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: units.gu(2)
                        color: Qt.rgba(0,0,0,0)
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: UbuntuColors.ash
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
                                "preset": "private_chat"
                            }
                            var _mainStack = mainStack
                            matrix.post( "/client/r0/createRoom", data, function (res) {
                                if ( res.room_id ) _mainStack.toChat ( res.room_id )
                            } )
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
