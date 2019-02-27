// File: ChatListPageActions.js
// Description: Actions for ChatListPage.qml

function loadFromDatabase () {

    // On the top are the rooms, which the user is invited to
    var res = storage.query ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url, rooms.unread, " +
    " events.id AS eventsid, ifnull(events.origin_server_ts, DateTime('now')) AS origin_server_ts, events.content_body, events.sender, events.state_key, events.content_json, events.type " +
    " FROM Chats rooms LEFT JOIN Events events " +
    " ON rooms.id=events.chat_id " +
    " WHERE rooms.membership!='leave' " +
    " AND (events.origin_server_ts IN (" +
    " SELECT MAX(origin_server_ts) FROM Events WHERE chat_id=rooms.id " +
    ") OR rooms.membership='invite')" +
    " GROUP BY rooms.id " +
    " ORDER BY origin_server_ts DESC " )
    // We now write the rooms in the column
    for ( var i = 0; i < res.rows.length; i++ ) {
        var room = res.rows.item(i)
        var body = room.content_body || ""
        room.content = JSON.parse(room.content_json)
        if ( room.type !== "m.room.message" ) {
            room.content_body = EventDescription.getDisplay ( room )
        }
        // We request the room name, before we continue
        model.append ( { "room": room } )
    }
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
    if ( !(eventType === "timeline" || type === "m.typing" || type === "m.room.name" || type === "m.room.avatar" || type === "m.receipt") ) return

    // Search the room in the model
    var j = 0
    for ( j = 0; j < model.count; j++ ) {
        if ( model.get(j).room.id === chat_id ) break
    }
    if ( j === model.count ) return
    var tempRoom = model.get(j).room

    if ( eventType === "timeline" ) {
        // Update the last message preview
        var body = lastEvent.content.body || ""
        if ( type !== "m.room.message" ) {
            body = EventDescription.getDisplay ( lastEvent )
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
    else if ( type === "m.receipt" && lastEvent.user === matrix.matrixid ) {
        // Update the room avatar
        tempRoom.unread = lastEvent.ts
    }
    else if ( type === "m.room.member" && (tempRoom.topic === "" || tempRoom.topic === null || tempRoom.avatar_url === "" || tempRoom.avatar_url === null) ) {
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
