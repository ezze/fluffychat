// File: ChatAliasSettingsPageActions.js
// Description: Actions for ChatAliasSettingsPage.qml

function update ( type, chat_id, eventType, eventContent ) {
    if ( activeChat !== chat_id ) return
    var matchTypes = [ "m.room.aliases", "m.room.canonical_alias" ]
    if ( matchTypes.indexOf( type ) !== -1 ) init ()
}

function init () {
    var res = storage.query ( "SELECT Chats.canonical_alias, Chats.power_event_canonical_alias, Chats.power_event_aliases, Memberships.power_level " +
    " FROM Chats, Memberships WHERE Chats.id=? AND Memberships.chat_id=? AND Memberships.matrix_id=?",
    [ activeChat, activeChat, matrix.matrixid ])
    canEditCanonicalAlias = res.rows[0].power_event_canonical_alias <= res.rows[0].power_level
    canEditAddresses = res.rows[0].power_event_aliases <= res.rows[0].power_level
    var canonical_alias = res.rows[0].canonical_alias

    // Get all addresses
    var response = storage.query ( "SELECT address FROM Addresses WHERE chat_id=?", [ activeChat ] )
    addresses = response.rows
    model.clear()
    for ( var i = 0; i < response.rows.length; i++ ) {
        console.log(response.rows[i].address)
        model.append({
            name: response.rows[ i ].address,
            isCanonicalAlias: response.rows[ i ].address === canonical_alias
        })
    }
    if ( response.rows.length === 0 ) PopupUtils.open( addAliasDialog )
}
