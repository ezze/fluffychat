import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

Page {
    id: userSettingsPage
    property var matrix_id: ""
    property var displayname: ""

    Rectangle {
        id: background
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
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

        var res = storage.query ( "SELECT displayname, avatar_url, presence, last_active_ago, currently_active FROM Users WHERE matrix_id=?", [ matrix_id ] )
        if ( res.rows.length === 1 ) profileRow.avatar_url = res.rows[0].avatar_url
        if ( res.rows[0].displayname !== "" && res.rows[0].displayname !== null ) {
            displayname = res.rows[0].displayname
        }
        profileRow.presence = res.rows[0].presence
        profileRow.last_active_ago = res.rows[0].last_active_ago
        profileRow.currently_active = res.rows[0].currently_active

        if ( matrix_id === settings.matrixid ) return
        res = storage.query ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url " +
        " FROM Chats rooms, Memberships memberships " +
        " WHERE (memberships.membership='join' OR memberships.membership='invite') " +
        " AND memberships.matrix_id=? " +
        " AND memberships.chat_id=rooms.id " +
        " ORDER BY rooms.topic "
        , [ matrix_id ] )
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


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - userHeader.height
        anchors.top: userHeader.bottom
        contentItem: Column {
            width: userSettingsPage.width

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

            ListSeperator {
                text: matrix_id !== settings.matrixid ? i18n.tr("Chats with this user:") : i18n.tr("You are that!")
            }

            Column {
                id: chatListView
                width: parent.width
                visible: matrix_id !== settings.matrixid
            }

            ListItem {
                id: startNewChatButton
                height: layout.height
                color: Qt.rgba(0,0,0,0)
                visible: matrix_id !== settings.matrixid
                onClicked: {
                    bottomEdgePageStack.pop ()

                    var data = {
                        "invite": [ matrix_id ],
                        "is_direct": true,
                        "preset": "trusted_private_chat"
                    }

                    var successCallback = function (res) {
                        if ( typeof res.room_id === "string" ) mainLayout.toChat ( res.room_id )
                        toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
                    }

                    matrix.post( "/client/r0/createRoom", data, successCallback, null, 2 )
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
