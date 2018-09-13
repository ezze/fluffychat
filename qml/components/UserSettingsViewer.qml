import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

BottomEdge {

    id: userSettingsViewer
    height: parent.height * (3/4)

    onCollapseCompleted: userSettingsViewer.destroy ()
    Component.onCompleted: commit()

    contentComponent: Page {
            property var matrix_id: ""
            property var displayname: ""
            height: userSettingsViewer.height

            FcPageHeader {
                id: userHeader
                title: ""
            }

            Component.onCompleted:  {
                matrix_id = activeUser
                displayname = usernames.getById ( matrix_id )
                avatar.name = displayname
                userHeader.title = matrix_id.replace(":","<font color='%1'>:".arg(UbuntuColors.graphite)) + "</font>"

                storage.transaction ( "SELECT avatar_url FROM Users WHERE matrix_id='" + matrix_id + "'", function ( res ) {
                    if ( res.rows.length === 1 ) avatar.mxc = res.rows[0].avatar_url
                })

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

                    Rectangle {
                        width: parent.width
                        height: units.gu(2)
                        color: Qt.rgba(0,0,0,0)
                    }

                    Avatar {  // Useravatar
                        id: avatar
                        //name: displayname
                        width: parent.width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        mxc: ""
                        onClickFunction: function () {
                            if ( mxc !== "" ) {
                                userSettingsViewer.collapse ()
                                imageViewer.show ( mxc )
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
                        height: 1
                        color: UbuntuColors.porcelain
                    }

                    ListItem {
                        id: startNewChatButton
                        height: layout.height
                        color: Qt.rgba(0,0,0,0)
                        onClicked: {
                            userSettingsViewer.collapse ()
                            var data = {
                                "invite": [ matrix_id ],
                                "is_direct": true,
                                "preset": "private_chat"
                            }
                            matrix.post( "/client/r0/createRoom", data )
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
                            text: i18n.tr("Chats with this user:")
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
                        color: UbuntuColors.porcelain
                    }

                    Column {
                        id: chatListView
                        width: parent.width
                    }


                }
            }


    }
}
