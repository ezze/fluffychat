// File: DefaultLayoutActions.js
// Description: Actions for DefaultmainLayout.qml


function toChat( chatID, toInvitePage ) {
    if ( activeChat === chatID ) return
    activeChat = chatID
    if ( toInvitePage ) {
        mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("../pages/InvitePage.qml"))
    }
    else {
        mainLayout.addPageToNextColumn ( mainLayout.primaryPage, Qt.resolvedUrl("../pages/ChatPage.qml"))
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
