import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent
    id: chatListPage

    property var searching: false

    onSearchingChanged: {
        if ( searching ) {
            for( var i = 0; i < model.count; i++ ) tempModel.append ( model.get(i) )
            matrix.get ( "/client/r0/publicRooms", { limit: 1000 }, function ( res ) {
                for( var i = 0; i < res.chunk.length; i++ ) {
                    var chat = res.chunk[i]
                    tempModel.append ( { "room": {
                        id: chat.room_id,
                        topic: chat.name || i18n.tr("Nameless chat"),
                        membership: "leave",
                        avatar_url: chat.avatar_url || "",
                        origin_server_ts: new Date().getTime(),
                        typing: [],
                        notification_count: 0,
                        highlight_count: 0
                    } } )
                }
                enabled = true
            } )
            chatListView.model = tempModel
        }
        else {
            chatListView.model = model
            tempModel.clear ()
        }
    }


    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    Component.onCompleted: {

        // On the top are the rooms, which the user is invited to
        storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url, " +
        " events.id AS eventsid, ifnull(events.origin_server_ts, DateTime('now')) AS origin_server_ts, events.content_body, events.sender, events.content_json, events.type " +
        " FROM Chats rooms LEFT JOIN Events events " +
        " ON rooms.id=events.chat_id " +
        " WHERE rooms.membership!='leave' " +
        " AND (events.origin_server_ts IN (" +
        " SELECT MAX(origin_server_ts) FROM Events WHERE chat_id=rooms.id " +
        // " AND type='m.room.message' " +
        ") OR rooms.membership='invite')" +
        " GROUP BY rooms.id " +
        " ORDER BY origin_server_ts DESC "
        , function(res) {
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                var body = room.content_body || ""
                room.content = JSON.parse(room.content_json)
                if ( room.type !== "m.room.message" ) {
                    room.content_body = displayEvents.getDisplay ( room )
                }
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
    function newChatUpdate ( chat_id, membership, notification_count, highlight_count, limitedTimeline ) {
        // Update the chat list item.
        // Search the room in the model
        var j = 0
        for ( j = 0; j < model.count; j++ ) {
            if ( model.get(j).room.id === chat_id ) break
        }

        // Does the chat already exist in the list model?
        if ( j === model.count && membership !== "leave" ) {
            var position = membership === "invite" ? 0 : j
            var timestamp = membership === "invite" ? new Date().getTime() : 0
            // Add the new chat to the list
            var newRoom = {
                "id": chat_id,
                "topic": "",
                "membership": membership,
                "highlight_count": highlight_count,
                "notification_count": notification_count,
                "origin_server_ts": timestamp
            }
            model.insert ( position, { "room": newRoom } )
        }
        // If the membership is "leave" then remove the item and stop here
        else if ( j !== model.count && membership === "leave" ) model.remove( j )
        else if ( membership !== "leave" ){
            // Update the rooms attributes:
            var tempRoom = model.get(j).room
            tempRoom.membership = membership
            tempRoom.notification_count = notification_count
            tempRoom.highlight_count = highlight_count
            model.set ( j, { "room": tempRoom })
        }
    }


    function newEvent ( type, chat_id, eventType, lastEvent ) {
        // Is the event necessary for the chat list? If not, then return
        if ( !(eventType === "timeline" || type === "m.typing" || type === "m.room.name" || type === "m.room.avatar") ) return

        // Search the room in the model
        var j = 0
        for ( j = 0; j < model.count; j++ ) {
            if ( model.get(j).room.id === chat_id ) break
        }
        if ( j === model.count ) return
        var tempRoom = model.get(j).room

    if ( eventType === "timeline"/* && (type === "m.room.message" || type === "m.sticker")*/ ) {
        // Update the last message preview
        var body = lastEvent.content.body || ""
        if ( type !== "m.room.message" ) {
            body = displayEvents.getDisplay ( lastEvent )
        }
        tempRoom.eventsid = lastEvent.event_id
        tempRoom.origin_server_ts = lastEvent.origin_server_ts
        tempRoom.content_body = body
        tempRoom.sender = lastEvent.sender
        tempRoom.content_json = JSON.stringify( lastEvent.content )
        tempRoom.type = lastEvent.type
    }
    if ( type === "m.typing" ) {
        // Update the typing list
        tempRoom.typing = lastEvent
    }
    else if ( type === "m.room.name" ) {
        // Update the room name
        tempRoom.topic = lastEvent.content.name
    }
    else if ( type === "m.room.avatar" ) {
        // Update the room avatar
        tempRoom.avatar_url = lastEvent.content.url
    }
    else if ( type === "m.room.member" && ((tempRoom.topic === "" || tempRoom.topic === null) || (tempRoom.avatar_url === "" || tempRoom.avatar_url === null)) ) {
        // Update the room name or room avatar calculation
        model.remove ( j )
        model.insert ( j, { "room": tempRoom })
    }
    model.set ( j, { "room": tempRoom })

    // Now reorder this item
    var here = j
    while ( j > 0 && tempRoom.origin_server_ts > model.get(j-1).room.origin_server_ts ) j--
    if ( here !== j ) model.move( here, j, 1 )
}


Connections {
    target: events
    onNewChatUpdate: newChatUpdate ( chat_id, membership, notification_count, highlight_count, limitedTimeline )
    onNewEvent: newEvent ( type, chat_id, eventType, eventContent )
}

header: StyledPageHeader {
    id: header
    title: shareObject === null ? i18n.tr("FluffyChat") : i18n.tr("Share")
    flickable: chatListView

    leadingActionBar {
        actions: [
        Action {
            iconName: "close"
            visible: shareObject !== null
            onTriggered: shareObject = null
        }]
    }

    trailingActionBar {
        actions: [
        Action {
            iconName: "search"
            onTriggered: searching = searchField.focus = true
        },
        Action {
            iconName: "account"
            visible: shareObject === null
            onTriggered: {
                searching = false
                searchField.text = ""
                mainStack.toStart ()
                mainStack.push(Qt.resolvedUrl("./SettingsPage.qml"))
            }
        },
        Action {
            iconName: "add"
            visible: shareObject === null
            onTriggered: {
                    mainStack.toStart ()
                    mainStack.push(Qt.resolvedUrl("./CreateChatPage.qml"))
            }
        }
        ]
    }
}


LeaveChatDialog { id: leaveChatDialog }


TextField {
    id: searchField
    objectName: "searchField"
    z: 5
    property var searchMatrixId: false
    property var upperCaseText: displayText.toUpperCase()
    property var tempElement: null
    anchors {
        top: header.bottom
        topMargin: units.gu(1)
        bottomMargin: units.gu(1)
        left: parent.left
        right: parent.right
        rightMargin: units.gu(2)
        leftMargin: units.gu(2)
    }
    onDisplayTextChanged: {
        if ( displayText !== "" && !searching ) searching = true
        else if ( displayText === "" ) searching = false
        if ( tempElement ) {
            tempModel.remove ( tempModel.count - 1 )
            tempElement  = false
        }

        if ( displayText.slice( 0,1 ) === "#" ) {
            searchMatrixId = displayText
            if ( searchMatrixId.indexOf(":") === -1 ) searchMatrixId += ":%1".arg(settings.server)


            tempModel.append ( { "room": {
                id: searchMatrixId,
                topic: searchMatrixId,
                membership: "leave",
                avatar_url: "",
                origin_server_ts: new Date().getTime(),
                typing: [],
                notification_count: 0,
                highlight_count: 0
            } } )
            tempElement = true
        }
    }
    inputMethodHints: Qt.ImhNoPredictiveText
    placeholderText: i18n.tr("Search for chats or public rooms...")
}

ListModel { id: model }
ListModel { id: tempModel }

ListView {
    id: chatListView
    width: parent.width
    height: parent.height - header.height
    anchors.top: parent.top
    anchors.topMargin: searchField.height + units.gu(2)
    delegate: ChatListItem {}
    model: model
    move: Transition {
        SmoothedAnimation { property: "y"; duration: 300 }
    }
    displaced: Transition {
        SmoothedAnimation { property: "y"; duration: 300 }
    }
}

Label {
    text: i18n.tr("Click on '+' to start a chat")
    textSize: Label.Large
    color: UbuntuColors.graphite
    anchors.centerIn: parent
    visible: model.count === 0 && !searching
}

}
