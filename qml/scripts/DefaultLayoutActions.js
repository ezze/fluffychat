// File: DefaultLayoutActions.js
// Description: Actions for DefaultmainLayout.qml


function toChat( chatID, toInvitePage ) {
    var rs = storage.query ( "SELECT * FROM Chats WHERE id=?", [ chatID ] )
    if ( rs.rows.length > 0 ) {
        if ( activeChat === chatID ) return
        activeChat = chatID
        if ( toInvitePage ) {
            mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("../pages/InvitePage.qml"))
        }
        else {
            mainLayout.addPageToNextColumn ( mainLayout.primaryPage, chatPage)
            chatPage.load()
        }
    }
    else {
        showConfirmDialog ( i18n.tr("Do you want to join this chat?").arg(chat_id), function () {
            matrix.post( "/client/r0/join/" + encodeURIComponent(chat_id), null, function ( response ) {
                matrix.waitForSync()
                mainLayout.toChat( response.room_id )
            }, null, 2 )
        } )
    }
}


function getPrimaryPage () {
    if ( matrix.isLogged && mainLayout.updateInfosFinished === version ) {
        return "../pages/ChatListPage.qml"
    }
    else if ( mainLayout.walkthroughFinished && mainLayout.updateInfosFinished === version ){
        return "../pages/LoginPage.qml"
    }
    else {
        return "../pages/WalkthroughPage.qml"
    }
}


function init () {
    mainLayout.primaryPageSource = Qt.resolvedUrl(getPrimaryPage ())
    mainLayout.removePages( mainLayout.primaryPage )
}
