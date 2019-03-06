// File: SimpleChatListItemActions.js
// Description: Actions for SimpleChatListItem.qml

function init () {

    // Get the room name
    if ( room.topic !== "" ) layout.title.text = room.topic
    else MatrixNames.getChatAvatarById ( room.id, function (displayname) {
        layout.title.text = displayname
        avatar.name = displayname
        // Is there a typing notification?
        if ( room.typing && room.typing.length > 0 ) {
            layout.subtitle.text = MatrixNames.getTypingDisplayString ( room.typing, displayname )
        }
    })

    // Get the room avatar if single chat
    if ( avatar.mxc === "") MatrixNames.getAvatarFromSingleChat ( room.id, function ( avatar_url ) {
        avatar.mxc = avatar_url
    } )
}
