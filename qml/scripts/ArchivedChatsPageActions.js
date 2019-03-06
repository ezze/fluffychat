// File: ArchivedChatsPageActions.js
// Description: Actions for ArchivedChatsPage.qml

function update () {

    // On the top are the rooms, which the user is invited to
    var res = storage.query ("SELECT rooms.id, rooms.topic, rooms.avatar_url " +
    " FROM Chats rooms " +
    " WHERE rooms.membership='leave' " +
    " ORDER BY rooms.topic DESC ")
    model.clear ()
    // We now write the rooms in the column
    for ( var i = 0; i < res.rows.length; i++ ) {
        var room = res.rows.item(i)
        // We request the room name, before we continue
        model.append ( { "room": room } )
    }
}
