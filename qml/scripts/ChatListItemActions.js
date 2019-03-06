// File: ChatListItemActions.js
// Description: Actions for ChatListItem.qml

function toChat () {
    if ( room.membership !== "leave" ) {
        activeChatTypingUsers = room.typing || []
        mainLayout.toChat ( room.id )
    }
    else mainLayout.toChat ( room.id )
    searchField.text = ""
    searching = false
}


function calcTitle () {
    if ( room.topic !== "" && room.topic !== null ) {
        return room.topic
    }
    else {
        return MatrixNames.getChatAvatarById ( room.id )
    }
}


function calcSubtitle () {
    if ( room.membership === "invite" ) {
        return i18n.tr("You have been invited to this chat")
    }
    else if ( room.membership === "leave" ) {
        return i18n.tr("You have left this chat")
    }
    else if ( room.typing && room.typing.length > 0 ) {
        return MatrixNames.getTypingDisplayString ( room.typing, layout.title.text )
    }
    else if ( room.content_body ) {
        if ( room.sender === matrix.matrixid ) {
            return i18n.tr("You: ") + room.content_body
        }
        else {
            return room.content_body
        }
    }
    else {
        return i18n.tr("No previous messages")
    }
}


function calcAvatar () {
    if ( room.avatar_url !== "" && room.avatar_url !== null && room.avatar_url !== undefined ) {
        return room.avatar_url
    }
    else {
        return MatrixNames.getAvatarFromSingleChat ( room.id )
    }
}


function remove () {
    var deleteAction = function () {
        matrix.post ( "/client/r0/rooms/%1/leave".arg(room.id), null, null, null, 2 )
    }
    showConfirmDialog ( i18n.tr("Do you want to leave this chat?"), deleteAction )
}
