// File: ChatEventActions.js
// Description: Actions for ChatEvent.qml

// Request more previous events from the server
function requestHistory ( event_id ) {
    if ( initialized !== model.count || requesting || (model.count > 0 && model.get( model.count -1 ).event.type === "m.room.create") ) return
    requesting = true
    var rs = storage.query ( "SELECT prev_batch FROM Chats WHERE id=?", [ activeChat ] )
    if ( rs.rows.length === 0 ) return
    var data = {
        from: rs.rows[0].prev_batch,
        dir: "b",
        limit: historyCount
    }

    var historyRequestCallback = function ( result ) {
        if ( result.chunk.length > 0 ) {
            var eventFound = false
            for ( var i = 0; i < result.chunk.length; i++ ) {
                if ( event_id && !eventFound && event_id === result.chunk[i].event_id ) eventFound = i
                addEventToList ( result.chunk[i], true )
            }
            matrix.handleRoomEvents ( activeChat, result.chunk, "history" )
            requesting = false
            storage.query ( "UPDATE Chats SET prev_batch=? WHERE id=?", [ result.end, activeChat ])
        }
        else requesting = false
        if ( event_id ) {
            if ( eventFound !== false ) {
                currentIndex = count - 1 - historyCount + eventFound
                matrix.post ( "/client/r0/rooms/%1/read_markers".arg(activeChat), { "m.fully_read": model.get(0).event.id }, null, null, 0 )
                currentIndex = count - 1 - historyCount + eventFound
            }
            else requestHistory ( event_id )
        }
    }

    var historyRequestErrorCallback = function () {
        requesting = false
    }

    matrix.get( "/client/r0/rooms/" + activeChat + "/messages", data, historyRequestCallback, historyRequestErrorCallback, event_id ? 2 : 1 )
}


function calcBubbleBackground ( isStateEvent, sent, status ) {
    if ( isStateEvent ) return theme.palette.normal.background
    else if ( !sent ) return incommingChatBubbleBackground
    else if (status < msg_status.SEEN ) return mainLayout.brighterMainColor
    else return mainLayout.mainColor
}

function resendMessage ( event ) {
    var body = event.content_body
    storage.query ( "DELETE FROM Events WHERE id=?", [ event.id ])
    removeEvent ( event.id )
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
        removeEvent ( event.id )
    }
    else showConfirmDialog ( i18n.tr("Are you sure?"), function () {
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
