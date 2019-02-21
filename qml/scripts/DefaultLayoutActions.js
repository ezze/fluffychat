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
    if ( matrix.isLogged && settings.updateInfosFinished === version ) {
        console.log("[Init] Start at chat list page")
        return "../pages/ChatListPage.qml"
    }
    else if ( settings.walkthroughFinished && settings.updateInfosFinished === version ){
        console.log("[Init] Start at chat login page")
        return "../pages/LoginPage.qml"
    }
    else {
        console.log("[Init] Start at chat walkthrough page")
        return "../pages/WalkthroughPage.qml"
    }
}


function init () {
    mainLayout.primaryPageSource = Qt.resolvedUrl(getPrimaryPage ())
    mainLayout.removePages( mainLayout.primaryPage )
}
