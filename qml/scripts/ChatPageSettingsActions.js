// File: ChatPageSettingsActions.js
// Description: Actions for ChatSettingsPage.qml


function init () {
    mainLayout.allowThreeColumns = true

    // Get the member status of the user himself
    var res = storage.query ( "SELECT description, avatar_url, membership, power_event_name, power_kick, power_ban, power_invite, power_event_power_levels, power_event_avatar FROM Chats WHERE id=?", [ activeChat ] )

    description = res.rows[0].description
    hasAvatar = (res.rows[0].avatar_url !== "" && res.rows[0].avatar_url !== null)

    var membershipResult = storage.query ( "SELECT * FROM Memberships WHERE chat_id=? AND matrix_id=?", [ activeChat, matrix.matrixid ] )
    if ( membershipResult.rows.length > 0 ) {
        membership = membershipResult.rows[0].membership
        power = membershipResult.rows[0].power_level
        canChangeName = power >= res.rows[0].power_event_name
        canKick = power >= res.rows[0].power_kick
        canBan = power >= res.rows[0].power_ban
        canInvite = power >= res.rows[0].power_invite
        canChangeAvatar = power >= res.rows[0].power_event_avatar
        canChangePermissions = power >= res.rows[0].power_event_power_levels
    }

    // Request the full memberlist, from the database AND from the server (lazy loading)
    model.clear()
    memberCount = 0
    for ( var mxid in activeChatMembers ) {
        var member = activeChatMembers[ mxid ]
        if ( member.membership === "join" ) memberCount++
        model.append({
            name: member.displayname || MatrixNames.transformFromId( mxid ),
            matrixid: mxid,
            membership: member.membership,
            avatar_url: member.avatar_url,
            userPower: member.power_level || 0
        })
    }
    memberList.positionViewAtBeginning ()

    if ( matrix.lazy_load_members ) {
        matrix.get ( "/client/r0/rooms/%1/members".arg(activeChat), {}, function ( response ) {
            model.clear()
            memberCount = 0
            for ( var i = 0; i < response.chunk.length; i++ ) {
                var member = response.chunk[ i ]

                var userPower = 0
                if ( activeChatMembers[member.state_key] ) {
                    userPower = activeChatMembers[member.state_key].power_level
                }

                if ( member.content.membership === "join" ) memberCount++

                activeChatMembers [member.state_key] = member.content
                if ( activeChatMembers [member.state_key].displayname === undefined || activeChatMembers [member.state_key].displayname === null || activeChatMembers [member.state_key].displayname === "" ) {
                    activeChatMembers [member.state_key].displayname = MatrixNames.transformFromId ( member.state_key )
                }
                if ( activeChatMembers [member.state_key].avatar_url === undefined || activeChatMembers [member.state_key].avatar_url === null ) {
                    activeChatMembers [member.state_key].avatar_url = ""
                }
                activeChatMembers[member.state_key].power_level = userPower

                model.append({
                    name: activeChatMembers [member.state_key].displayname,
                    matrixid: member.state_key,
                    membership: member.content.membership,
                    avatar_url: activeChatMembers [member.state_key].avatar_url,
                    userPower: activeChatMembers[member.state_key].power_level
                })

            }
            memberList.positionViewAtBeginning ()
        })
    }
}


function update ( type, chat_id, eventType, eventContent ) {
    if ( activeChat !== chat_id ) return
    var matchTypes = [ "m.room.member", "m.room.topic", "m.room.power_levels", "m.room.avatar", "m.room.name" ]
    if ( matchTypes.indexOf( type ) !== -1 ) init ()
}

function getDisplayMemberStatus ( membership ) {
    if ( membership === "join" ) return i18n.tr("Member")
    else if ( membership === "invite" ) return i18n.tr("Was invited")
    else if ( membership === "leave" ) return i18n.tr("Has left the chat")
    else if ( membership === "knock" ) return i18n.tr("Has knocked")
    else if ( membership === "ban" ) return i18n.tr("Was banned from the chat")
    else return i18n.tr("Unknown")
}

function changePowerLevel ( level ) {
    var data = {
        users: {}
    }
    data.users[selectedUserId] = level
    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
}

function destruct () {
    mainLayout.allowThreeColumns = false
    if ( true ) return // TODO: Detect if user goes back to chat list page
    chatActive = false
    activeChat = null
}
