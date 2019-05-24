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

    canChangePermissions = ownPower >= res.rows[0].power_event_power_levels
    canChangeAccessRules = ownPower >= res.rows[0].power_state_default
    canChangeHistoryRules = ownPower >= res.rows[0].power_event_history_visibility
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


function initEncryption () {
    var init = function () {
        matrix.put("/client/r0/rooms/%1/state/m.room.encryption".arg(activeChat), {"algorithm":"m.megolm.v1.aes-sha2"}, function () { initEncryption.visible=false }, null, 2)
    }
    showConfirmDialog (i18n.tr("This can not be undone!"), init)
}
