// File: ArchivedChatListItemActions.js
// Description: Actions for ArchivedChatListItem.qml

function clear ( chat_id ) {
    matrix.post( "/client/r0/rooms/%1/forget".arg( chat_id ) )
    storage.query ( "DELETE FROM Memberships WHERE chat_id=?", [ chat_id ] )
    storage.query ( "DELETE FROM Events WHERE chat_id=?", [ chat_id ] )
    storage.query ( "DELETE FROM Chats WHERE id=?", [ chat_id ] )
    archivedChatListPage.update ()
}
