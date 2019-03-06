// File: ChatEventActions.js
// Description: Actions for ChatEvent.qml

function calcBubbleBackground ( isStateEvent, sent, status ) {
    if ( isStateEvent ) return theme.palette.normal.background
    else if ( !sent ) return incommingChatBubbleBackground
    else if (status < msg_status.SEEN ) return mainLayout.brighterMainColor
    else return mainLayout.mainColor
}

function resendMessage ( event ) {
    var body = event.content_body
    storage.query ( "DELETE FROM Events WHERE id=?", [ event.id ])
    chatPage.removeEvent ( event.id )
    chatPage.send ( body )
}

function startReply ( event ) {
    chatPage.replyEvent = event
    messageTextField.focus = true
}


function addAsSticker ( event ) {
    showConfirmDialog ( i18n.tr("Add to sticker collection?"), function () {
        storage.query( "INSERT OR IGNORE INTO Media VALUES(?,?,?,?)", [
        "image/gif",
        event.content.url,
        event.content.url,
        event.content.url
        ], function ( result ) {
            if ( result.rowsAffected == 0 ) toast.show (i18n.tr("Already added as sticker"))
            else toast.show (i18n.tr("Added as sticker"))
        })
    } )
}

function share ( isMediaEvent, senderDisplayname, event ) {
    if ( !isMediaEvent ) {
        contentHub.shareTextIntern ("%1 (%2): %3".arg( senderDisplayname ).arg( MatrixNames.getChatTime (event.origin_server_ts) ).arg( event.content.body ))
    }
    else contentHub.shareFileIntern( event.content )
}

function removeEvent ( event ) {
    if ( event.status === msg_status.ERROR ) {
        storage.query ( "DELETE FROM Events WHERE id=?", [ event.id ] )
        chatPage.removeEvent ( event.id )
    }
    else showConfirmDialog ( i18n.tr("Remove this message?"), function () {
        matrix.put( "/client/r0/rooms/%1/redact/%2/%3"
        .arg(activeChat)
        .arg(event.id)
        .arg(new Date().getTime()) )
    })
}

function toggleAudioPlayer ( event ) {
    if ( audio.source !== MatrixNames.getLinkFromMxc ( event.content.url ) ) {
        audio.source = MatrixNames.getLinkFromMxc ( event.content.url )
    }
    if ( playing ) audio.pause ()
    else audio.play ()
    playing = !playing
}
