// File: ChangeChatNameDialogActions.js
// Description: Actions for ChangeChatNameDialog.qml

function save ( chatnameTextField, descriptionTextField, dialogue ) {

    // Change the name if the user has changed it
    if ( chatnameTextField.displayText !== chatName ) {
        var messageID = Math.floor((Math.random() * 1000000) + 1)
        matrix.put( "/client/r0/rooms/%1/send/m.room.name/%2".arg(activeChat).arg(messageID),
        {
            name: chatnameTextField.displayText
        } )
    }

    // Change the description if the user has changed it
    if ( descriptionTextField.displayText !== description ) {
        var messageID2 = Math.floor((Math.random() * 1000000) + 1)
        matrix.put( "/client/r0/rooms/%1/send/m.room.topic/%2".arg(activeChat).arg(messageID2),
        {
            topic: descriptionTextField.displayText
        } )
    }

    PopupUtils.close(dialogue)
}
