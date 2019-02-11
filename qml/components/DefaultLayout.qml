import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import "../pages"
import "../scripts/DefaultLayoutActions.js" as DefaultLayoutActions

Rectangle {

    id: layout
    color: "transparent"

    anchors.fill: parent

    /* =============================== LAYOUT ===============================

    The main page stack is the current layout of the app.
    */

    // Check if there are username, password and domain saved from a previous
    // session and autoconnect with them. If not, then just go to the login Page.

    function push ( page ) { mainStack.push ( page ) }
    function pop () { mainStack.pop () }
    function clear () { mainStack.clear () }

    function init () {
        mainStack.clear ()
        sideStack.clear ()
        if ( settings.token && settings.updateInfosFinished === version ) {
            if ( tabletMode ) {
                mainStack.push( Qt.resolvedUrl("../pages/BlankPage.qml") )
                sideStack.push(Qt.resolvedUrl("../pages/ChatListPage.qml"))
            }
            else mainStack.push(Qt.resolvedUrl("../pages/ChatListPage.qml"))
            matrix.onlineStatus = true
            matrix.init ()
        }
        else if ( settings.walkthroughFinished && settings.updateInfosFinished === version ){
            mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
        }
        else {
            mainStack.push(Qt.resolvedUrl("../pages/WalkthroughPage.qml"))
        }
    }

    ProgressBar {
        id: requestProgressBar
        indeterminate: true
        width: parent.width
        anchors.top: parent.top
        visible: progressBarRequests > 0
        z: 10
    }

    Rectangle {
        anchors.fill: sideStack
        color: theme.palette.normal.background
        z: 4
        visible: sideStack.visible
    }

    PageStack {
        id: sideStack
        visible: tabletMode
        anchors.fill: undefined
        anchors.left: parent.left
        anchors.top: parent.top
        width: tabletMode ? units.gu(45) : parent.width
        height: parent.height
        z: 5
    }

    Rectangle {
        height: parent.height
        visible: tabletMode
        width: units.gu(0.1)
        color: UbuntuColors.silk
        anchors.top: parent.top
        anchors.left: sideStack.right
        z: 11
    }

    StackView {
        id: mainStack
        anchors.fill: undefined
        anchors.right: parent.right
        anchors.top: parent.top
        width: tabletMode ? parent.width - units.gu(45) : parent.width
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
        height: parent.height
    }


    signal toStart ( var page )
    signal toChat ( var chatID )

    onToStart: DefaultLayoutActions.toStart ( page )
    onToChat: DefaultLayoutActions.toChat ( chatID )
}
