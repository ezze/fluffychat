// File: UserPageActions.js
// Description: Actions for UserPage.qml

function init () {
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

    if ( matrix_id === matrix.matrixid ) return
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


function startPrivateChat () {

    var data = {
        "invite": [ matrix_id ],
        "is_direct": true,
        "preset": "trusted_private_chat"
    }

    var successCallback = function (res) {
        bottomEdgePageStack.pop ()
        mainLayout.toChat ( res.room_id )
    }

    matrix.post( "/client/r0/createRoom", data, successCallback, null, 2 )
}
