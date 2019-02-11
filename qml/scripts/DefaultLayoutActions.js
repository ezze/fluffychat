// File: DefaultLayoutActions.js
// Description: Actions for DefaultLayout.qml



function getPath ( page ) {
    return "../pages/%1Page.qml".arg( page )
}


function toStart ( page ) {
    while (depth > 1) pop()
    if ( page ) mainStack.push (Qt.resolvedUrl( page ))
}


function toChat( chatID ) {
    if ( activeChat === chatID ) return
    mainStack.toStart ()
    activeChat = chatID
    mainStack.push (Qt.resolvedUrl("./pages/ChatPage.qml"))
}
