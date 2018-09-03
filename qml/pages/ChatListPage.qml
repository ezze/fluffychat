import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    id: chatListPage


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    Component.onCompleted: {

        // On the top are the rooms, which the user is invited to
        storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, " +
        " events.id AS eventsid, ifnull(events.origin_server_ts, DateTime('now')) AS origin_server_ts, events.content_body, events.sender, events.content_json, events.type " +
        " FROM Chats rooms LEFT JOIN Events events " +
        " ON rooms.id=events.chat_id " +
        " WHERE rooms.membership!='leave' " +
        " AND (events.origin_server_ts IN (" +
        " SELECT MAX(origin_server_ts) FROM Events WHERE chat_id=rooms.id " +
        ") OR rooms.membership='invite')" +
        " ORDER BY origin_server_ts DESC "
        , function(res) {
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                // We request the room name, before we continue
                model.append ( { "room": room } )
            }
        })
    }


    /* When the app receives a new synchronization object, the chat list should be
    * updated, without loading it new from the database. There are several types
    * of changes:
    * - Join a new chat
    * - Invited to a chat
    * - Leave a chat
    * - New message in the last-message-field ( Which needs reordering the chats )
    * - Update the counter of unseen messages
    */
    function update ( sync ) {

        // This helper function helps us to reduce code. Chats with the type
        // "join" and "invite" are just handled the same, and "leave" is very
        // near to this
        for ( var type in sync.rooms ) {
            for ( var id in sync.rooms[type] ) {
                var room = sync.rooms[type][id]

                // Check if the user is already in this chat
                var roomExists = false
                var j = 0
                for ( j = 0; j < model.count; j++ ) {
                    if ( model.get(j).room.id === id ) {
                        roomExists = true
                        if ( type === "leave" ) model.remove( j )
                        break
                    }
                }

                // Nothing more to show for the type "leave"
                if ( type === "leave" ) return

                // Add the room to the list, if it does not exist
                var unread = room.unread_notifications && room.unread_notifications.notification_count || 0
                if ( !roomExists ) {
                    var newRoom = {
                        "id": id,
                        "topic": "",
                        "membership": type,
                        "notification_count": unread
                    }
                    // Put new invitations to the top
                    if ( type === "invite" ) newRoom.origin_server_ts = new Date().getTime()
                    model.append ( { "room": newRoom } )
                    j = model.count - 1
                }

                var tempRoom = model.get(j).room

                // Update the type
                tempRoom.membership = type

                // Update the notification count
                tempRoom.notification_count = unread

                // Check the timeline events and add the latest event to the chat list
                // as the latest message of the chat
                var newTimelineEvents = room.timeline && room.timeline.events.length > 0
                if ( newTimelineEvents ) {
                    var lastEvent = room.timeline.events[ room.timeline.events.length - 1 ]
                    tempRoom.eventsid = lastEvent.event_id
                    tempRoom.origin_server_ts = lastEvent.origin_server_ts
                    tempRoom.content_body = lastEvent.content.body || ""
                    tempRoom.sender = lastEvent.sender
                    tempRoom.content_json = JSON.stringify( lastEvent.content )
                    tempRoom.type = lastEvent.type
                }

                // Now reorder this item
                if ( newTimelineEvents || !roomExists ) {
                    while ( j > 0 && tempRoom.origin_server_ts > model.get(j-1).room.origin_server_ts ) {
                        model.remove ( j )
                        model.insert ( j-1, { "room": tempRoom } )
                        j--
                    }
                }

                model.remove ( j )
                model.insert ( j, { "room": tempRoom } )

                // Send message receipt
                if ( newTimelineEvents && activeChat === id && unread > 0 && lastEvent.event_id !== undefined ){
                    matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + lastEvent.event_id, null )
                }
            }
        }
    }


    function typing ( roomid, user_ids ) {
        for( var i = 0; i < model.count - 1; i++ ) {
            if ( model.get ( i ).room.id === roomid ) {
                var tempRoom = model.get( i ).room
                tempRoom.typing = user_ids
                model.remove ( i )
                model.insert ( i, { "room": tempRoom } )
                return
            }
        }
    }


    Connections {
        target: events
        onChatListUpdated: update ( response )
        onChatTypingEvent: typing ( roomid, user_ids )
    }


    header: FcPageHeader {
        id: header
        trailingActionBar {
            actions: [
            Action {
                iconName: "settings"
                onTriggered: {
                    mainStack.toStart ()
                    mainStack.push(Qt.resolvedUrl("./MainSettingsPage.qml"))
                }
            },
            Action {
                iconName: "add"
                onTriggered: {
                    mainStack.toStart ()
                    mainStack.push(Qt.resolvedUrl("./AddChatPage.qml"))
                }
            }
            ]
        }
    }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        delegate: ChatListItem {}
        model: ListModel { id: model }
    }

    Label {
        text: i18n.tr('Swipe from the bottom to start a new chat')
        anchors.centerIn: parent
        visible: model.count === 0
    }

    // ============================== BOTTOM EDGE ==============================
    BottomEdge {
        id: bottomEdge
        height: parent.height

        onCommitCompleted: {
            mainStack.toStart ()
            mainStack.push(Qt.resolvedUrl("./AddChatPage.qml"))
            collapse()
        }

        enabled: !tabletMode

        contentComponent: Rectangle {
            width: mainStackWidth
            height: root.height
            color: theme.palette.normal.background
            AddChatPage { }
        }
    }

}
