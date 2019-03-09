// File: DefaultLayoutActions.js
// Description: Actions for DefaultmainLayout.qml


function toChat( chatID, toInvitePage ) {
    if ( mainLayout.updateInfosFinished !== version ) mainLayout.updateInfosFinished = version
    var rs = storage.query ( "SELECT * FROM Chats WHERE id=? AND membership!='leave'", [ chatID ] )
    if ( rs.rows.length > 0 ) {
        bottomEdgePageStack.clear ()
        if ( activeChat === chatID ) return
        activeChat = chatID
        mainLayout.addPageToNextColumn ( mainLayout.primaryPage, chatPage)
        chatPage.load()
        if ( toInvitePage ) {
            bottomEdgePageStack.push ( Qt.resolvedUrl("../pages/InvitePage.qml") )
        }
    }
    else {
        var chatJoinedSuccess = function ( response ) {
            matrix.waitForSync()
            activeChat = chatID
            bottomEdgePageStack.clear ()
            mainLayout.addPageToNextColumn ( mainLayout.primaryPage, chatPage)
            chatPage.load()
        }
        var joinChatAction = function () {
            matrix.post( "/client/r0/join/" + encodeURIComponent(chatID), null, chatJoinedSuccess, null, 2 )
        }
        showConfirmDialog ( i18n.tr("Do you want to join this chat?"), joinChatAction )
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
    bottomEdgePageStack.clear ()
    mainLayout.primaryPageSource = Qt.resolvedUrl(getPrimaryPage ())
    mainLayout.removePages( mainLayout.primaryPage )
}
