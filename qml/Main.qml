import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.4
import "models"
import "components"
import "scripts/MatrixNames.js" as MatrixNames

/* =============================== MAIN.qml ===============================
This file is the start point of the app. It contains all important config variables,
instances of all controller, the layout (mainstack) and the start point.
*/

MainView {

    /* =============================== MAIN CONFIGS ===============================
    */
    id: root
    objectName: 'mainView'
    applicationName: 'fluffychat.christianpauly'
    automaticOrientation: true

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)
    theme: ThemeSettings {
        name: settings.darkmode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"
    }

    /* =============================== CONFIG VARIABLES ===============================

    This config variables are readonly!
    */
    readonly property var defaultMainColorH: 0.73
    readonly property var defaultDomain: "ubports.chat"
    readonly property var defaultIDServer: "vector.im"
    readonly property var defaultDeviceName: "UbuntuPhone"
    readonly property var miniTimeout: 3000
    readonly property var defaultTimeout: 30000
    readonly property var longPollingTimeout: 10000
    readonly property var typingTimeout: 30000
    readonly property var borderColor: settings.darkmode ? UbuntuColors.jet : UbuntuColors.silk
    readonly property var version: Qt.application.version
    readonly property var downloadPath: "/home/phablet/.local/share/ubuntu-download-manager/fluffychat.christianpauly/Downloads/"
    readonly property var msg_status: { "SENDING": 0, "SENT": 1, "RECEIVED": 2, "SEEN": 3, "HISTORY": 4, "ERROR": -1 }

    /* =============================== GLOBAL VARIABLES ===============================

    This variables are accessable everywhere just with the variable names.
    */
    property var activeChat: null
    property var activeCommunity: null
    property var chatActive: false
    property var activeChatDisplayName: null
    property var applicationState: Qt.application.state
    property var activeChatTypingUsers: []
    property var activeChatMembers: []
    property var activeUser: null
    property var progressBarRequests: 0
    property var waitingForSync: false
    property var appstatus: 4
    property var pushtoken: pushclient.token
    property var tabletMode: settings.token !== undefined && width > units.gu(90)
    property var prevMode: false
    property var mainStackWidth: mainStack.width
    property var desiredPhoneNumber: null
    property var desiredUsername: null
    property var consentUrl: ""
    property var consentContent: ""
    property var shareObject: null
    property var mainFontColor: settings.darkmode ? "#FFFFFF" : "#000000"
    property var mainBorderColor: settings.darkmode ? "#333333" : "#CCCCCC"
    property var bottomEdgeCommited: false


    
    /* =============================== MODELS ===============================

    All models should be defined here. They are accessable everywhere by the
    id, defined here.
    */
    StorageController { id: storage }
    MatrixModel { id: matrix }
    PushController { id: pushclient }
    SettingsController { id: settings }
    UserMetricsController { id: userMetrics }
    Toast { id: toast }
    ImageViewer { id: imageViewer }
    VideoPlayer { id: videoPlayer }
    UriController { id: uriController }
    ShareController { id: shareController }
    LoadingScreen { id: loadingScreen }
    LockedScreen { id: lockedScreen }
    LoadingModal { id: loadingModal }
    Audio { id: audio }
    ConfirmDialog { id: confirmDialog }
    DownloadDialog {
        id: downloadDialog
        property var current: null
        property var filename: null
        property var downloadUrl: null
        property var shareFunc: shareController.shareAll
    }
    Image {
        id: backgroundImage
        opacity: chatActive
        visible: settings.chatBackground !== undefined
        anchors.fill: mainStack
        source: settings.chatBackground || ""
        cache: true
        fillMode: Image.PreserveAspectCrop
        z: -1
        onStatusChanged: if (status == Image.Error) settings.chatBackground = undefined
    }

    // Simple universal confirmation dialog
    property var confirmDialogText: i18n.tr("Are you sure?")
    property var confirmDialogFunction: function () {}
    function showConfirmDialog ( text, action ) {
        confirmDialogText = text
        confirmDialogFunction = action
        PopupUtils.open( confirmDialog )
    }

    // Wait for server answer dialog
    WaitDialog { id: waitDialog }
    property var waitDialogRequest: null
    onWaitDialogRequestChanged: waitDialogRequest !== null ? PopupUtils.open ( waitDialog ) : function(){}




    /* =============================== LAYOUT ===============================

    The main page stack is the current layout of the app.
    */

    // Check if there are username, password and domain saved from a previous
    // session and autoconnect with them. If not, then just go to the login Page.
    function init () {
        mainStack.clear ()
        sideStack.clear ()
        if ( settings.token && settings.updateInfosFinished === version ) {
            if ( tabletMode ) {
                mainStack.push( Qt.resolvedUrl("./pages/BlankPage.qml") )
                sideStack.push(Qt.resolvedUrl("./pages/ChatListPage.qml"))
            }
            else mainStack.push(Qt.resolvedUrl("./pages/ChatListPage.qml"))
            matrix.onlineStatus = true
            matrix.init ()
        }
        else if ( settings.walkthroughFinished && settings.updateInfosFinished === version ){
            mainStack.push(Qt.resolvedUrl("./pages/LoginPage.qml"))
        }
        else {
            mainStack.push(Qt.resolvedUrl("./pages/WalkthroughPage.qml"))
        }
    }


    onTabletModeChanged: {
        if ( prevMode !== tabletMode ) {
            init ()
            prevMode = tabletMode
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


    /* =============================== CONNECTION MANAGER ===============================

    If the app suspend, then this will be triggered.
    */

    onActiveChatChanged: {
        MatrixNames.getChatAvatarById ( activeChat, function (name) {
            activeChatDisplayName = name
        } )
    }

    /* =============================== START POINT ===============================
    When the app starts, then this will be triggered!
    */
    Component.onCompleted: {
        storage.init ()
        init ()
    }
}
