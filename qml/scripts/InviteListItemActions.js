// File: InviteListItemActions.js
// Description: Helper function for a good invite UX

function invite ( matrixid, displayname ) {

    var inviteAction = function () {
        // Invite this user
        matrix.post ( "/client/r0/rooms/%1/invite".arg(activeChat),{ user_id: matrixid }, function () {
            toast.show( i18n.tr('%1 has been invited').arg(displayname) )
        }, function ( error) {
            if ( error.errcode === "M_UNKNOWN" ) toast.show ( i18n.tr('An error occured. Maybe the username %1 is wrong?').arg(matrixid) )
            else if ( error.errcode === "M_FORBIDDEN" ) toast.show ( i18n.tr('%1 is banned from the chat.').arg(matrixid) )
            else toast.show ( error.error )
        } )
    }
    showConfirmDialog ( i18n.tr("Invite %1 to this chat?").arg(displayname), inviteAction)
}
