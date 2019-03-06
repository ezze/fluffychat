// File: StartChat.js
// Description: Helper function to start a chat from a dialog.

function startChat ( dialogue ) {

    var successCallback = function (res) {
        if ( res.room_id ) mainLayout.toChat ( res.room_id )
        toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
    }

    var data = {
        "invite": [ activeUser ],
        "is_direct": true,
        "preset": "trusted_private_chat"
    }

    matrix.post( "/client/r0/createRoom", data, successCallback, null, 2 )
    PopupUtils.close(dialogue)
}
