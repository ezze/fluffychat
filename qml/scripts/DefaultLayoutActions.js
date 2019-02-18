// File: DefaultLayoutActions.js
// Description: Actions for DefaultmainLayout.qml


function toChat( chatID, toInvitePage ) {
    if ( activeChat === chatID ) return
    activeChat = chatID
    var newChatPage = Qt.resolvedUrl("../pages/ChatPage.qml")
    mainLayout.addPageToNextColumn ( mainLayout.primaryPage, newChatPage )
    if ( toInvitePage ) {
        mainLayout.addPageToNextColumn ( newChatPage, Qt.resolvedUrl("../pages/InvitePage.qml") )
    }
}


function getPrimaryPage () {
    if ( settings.token && settings.updateInfosFinished === version ) {
        return "../pages/ChatListPage.qml"
    }
    else if ( settings.walkthroughFinished && settings.updateInfosFinished === version ){
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
