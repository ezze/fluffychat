// File: UserSettingsDialogActions.js
// Description: Actions for UserSettingsDialog.qml

function init () {
    var res = storage.query ( "SELECT presence, last_active_ago, currently_active FROM Users WHERE matrix_id=?", [ activeUser ] )
    dialogue.presence = res.rows[0].presence
    dialogue.last_active_ago = res.rows[0].last_active_ago
    dialogue.currently_active = res.rows[0].currently_active

    if ( activeUser === matrix.matrixid ) return
    res = storage.query ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url " +
    " FROM Chats rooms, Memberships memberships " +
    " WHERE (memberships.membership='join' OR memberships.membership='invite') " +
    " AND memberships.matrix_id=? " +
    " AND memberships.chat_id=rooms.id " +
    " ORDER BY rooms.topic "
    , [ activeUser ] )
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
