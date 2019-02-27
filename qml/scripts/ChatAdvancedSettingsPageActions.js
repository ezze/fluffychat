// File: ChatAdvancedSettingsPageActions.js
// Description: Actions for ChatAdvancedSettingsPage.qml

function update ( type, chat_id, eventType, eventContent ) {
    if ( activeChat !== chat_id ) return
    var matchTypes = [ "m.room.power_levels", "m.room.member", "m.room.join_rules", "m.room.guest_access", "m.room.history_visibility" ]
    if ( matchTypes.indexOf( type ) !== -1 ) init ()
    matchTypes = [ "m.room.power_levels", "m.room.member" ]
    if ( matchTypes.indexOf( type ) !== -1 ) initPermissions ()
}

function init () {

    var rs = storage.query ( "SELECT power_level FROM Memberships WHERE chat_id=? AND matrix_id=?", [
    activeChat, matrix.matrixid ] )
    ownPower = rs.rows[0].power_level

    // Get the member status of the user himself
    var res = storage.query ( "SELECT * FROM Chats WHERE id=?", [ activeChat ] )

    matrix.waitingForAnswer++

    var join_rules = res.rows[0].join_rules
    invitedAllowed.isChecked = chatIsPublic.isChecked = false
    if ( join_rules === "invite" || join_rules === "public" ) invitedAllowed.isChecked = true
    if ( join_rules === "public" ) chatIsPublic.isChecked = true

    var guest_access = res.rows[0].guest_access
    guestsAllowed.isChecked = guest_access === "can_join"

    var history_visibility = res.rows[0].history_visibility
    invitedHistoryAccess.isChecked = sharedHistoryAccess.isChecked = worldHistoryAccess.isChecked = false
    if ( history_visibility === "invited" || history_visibility === "shared" || history_visibility === "world_readable" ) invitedHistoryAccess.isChecked = true
    if ( history_visibility === "shared" || history_visibility === "world_readable" ) sharedHistoryAccess.isChecked = true
    if ( history_visibility === "world_readable" ) worldHistoryAccess.isChecked = true

    matrix.waitingForAnswer--

    var rs = storage.query ( "SELECT power_level FROM Memberships WHERE chat_id=? AND matrix_id=?", [
    activeChat, matrix.matrixid ] )
    ownPower = rs.rows[0].power_level

    // Get the member status of the user himself
    var res = storage.query ( "SELECT * FROM Chats WHERE id=?", [ activeChat ] )

    power_events_default.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_events_default )
    power_events_default.icon = powerlevelToIcon ( res.rows[0].power_events_default )
    power_state_default.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_state_default )
    power_state_default.icon = powerlevelToIcon ( res.rows[0].power_state_default )
    power_redact.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_redact )
    power_redact.icon = powerlevelToIcon ( res.rows[0].power_redact )
    power_invite.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_invite )
    power_invite.icon = powerlevelToIcon ( res.rows[0].power_invite )
    power_ban.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_ban )
    power_ban.icon = powerlevelToIcon ( res.rows[0].power_ban )
    power_kick.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_kick )
    power_kick.icon = powerlevelToIcon ( res.rows[0].power_kick )
    power_user_default.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_user_default )
    power_user_default.icon = powerlevelToIcon ( res.rows[0].power_user_default )
    power_event_avatar.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_event_avatar )
    power_event_avatar.icon = powerlevelToIcon ( res.rows[0].power_event_avatar )
    power_event_history_visibility.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_event_history_visibility )
    power_event_history_visibility.icon = powerlevelToIcon ( res.rows[0].power_event_history_visibility )
    power_event_canonical_alias.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_event_canonical_alias )
    power_event_canonical_alias.icon = powerlevelToIcon ( res.rows[0].power_event_canonical_alias )
    power_event_aliases.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_event_canonical_alias )
    power_event_aliases.icon = powerlevelToIcon ( res.rows[0].power_event_aliases )
    power_event_name.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_event_name )
    power_event_name.icon = powerlevelToIcon ( res.rows[0].power_event_name )
    power_event_power_levels.value = MatrixNames.powerlevelToStatus ( res.rows[0].power_event_power_levels )
    power_event_power_levels.icon = powerlevelToIcon ( res.rows[0].power_event_power_levels )

    canChangePermissions = ownPower >= res.rows[0].power_event_power_levels
    canChangeAccessRules = ownPower >= res.rows[0].power_state_default
    canChangeHistoryRules = ownPower >= res.rows[0].power_event_history_visibility
}

function powerlevelToIcon ( power_level ) {
    if ( power_level < 50 ) return "account"
    else if ( power_level < 100 ) return "non-starred"
    else return "starred"
}


function changePowerLevel ( level ) {
    var data = {}
    if ( activePowerLevel.indexOf("m.room") !== -1 ) {
        data["events"] = {}
        data["events"][activePowerLevel] = level
    }
    else data[activePowerLevel] = level
    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data, 2 )
}


function switchInvitedAllowed ( isChecked ) {
    matrix.waitForSync ()
    if ( isChecked ) matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "invite" } )
    else matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "private" } )
}


function switchChatIsPublic ( isChecked ) {
    matrix.waitForSync ()
    if ( isChecked ) matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "public" } )
    else matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "invite" } )
}


function switchGuestsAllowed ( isChecked ) {
    matrix.waitForSync ()
    if ( isChecked ) matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.guest_access/", { "guest_access": "can_join" } )
    else matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.guest_access/", { "guest_access": "forbidden" } )
}


function switchInvitedHistoryAccess( isChecked ) {
    matrix.waitForSync ()
    if ( isChecked ) matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "invited" } )
    else matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "joined" } )
}


function switchSharedHistoryAccess ( isChecked ) {
    matrix.waitForSync ()
    if ( isChecked ) matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "shared" } )
    else matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "invited" } )
}


function switchWorldHistoryAccess ( isChecked ) {
    matrix.waitForSync ()
    if ( isChecked ) matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "world_readable" } )
    else matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "shared" } )
}


function changePermission ( powerLevel, name ) {
    if ( canChangeAccessRules ) {
        activePowerLevel = powerLevel
        powerLevelDescription = name
        contextualActions.show()
    }
}
