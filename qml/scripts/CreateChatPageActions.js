// File: CreateChatPageActions.js
// Description: Actions for CreateChatPage.qml

function updatePresence ( type, chat_id, eventType, eventContent ) {
    if ( type === "m.presence" ) {
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).matrix_id === eventContent.sender ) {
                model.set(i).presence = eventContent.presence
                if ( eventContent.last_active_ago ) model.set(i).last_active_ago = eventContent.last_active_ago
                break
            }
        }
    }
}


function update () {
    model.clear()
    var res = storage.query( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Users.presence, Users.last_active_ago, Contacts.medium, Contacts.address FROM Users LEFT JOIN Contacts " +
    " ON Contacts.matrix_id=Users.matrix_id WHERE Users.matrix_id!=? ORDER BY Contacts.medium DESC, LOWER(Users.displayname || replace(Users.matrix_id,'@','')) LIMIT 1000", [
    matrix.matrixid ] )
    for( var i = 0; i < res.rows.length; i++ ) {
        var user = res.rows[i]
        model.append({
            matrix_id: user.matrix_id,
            name: user.displayname || MatrixNames.transformFromId(user.matrix_id),
            avatar_url: user.avatar_url,
            medium: user.medium || "matrix",
            address: user.address || user.matrix_id,
            last_active_ago: user.last_active_ago,
            presence: user.presence,
            temp: false
        })
    }
}


function createNewGroup () {
    var createNewGroupCallback = function () {
        bottomEdge.collapse ()
        matrix.post( "/client/r0/createRoom", {
            preset: "private_chat"
        }, function ( response ) {
            toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
            mainLayout.toChat ( response.room_id, true )
        }, null, 2 )
    }
    showConfirmDialog ( i18n.tr("Do you want to create a new group now?"), createNewGroupCallback )
}
