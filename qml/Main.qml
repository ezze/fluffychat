import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.4
import "controller"
import "components"

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
    readonly property var defaultMainColorH: 0.72
    readonly property var defaultDomain: "ubports.chat"
    readonly property var defaultIDServer: "vector.im"
    readonly property var defaultDeviceName: "UbuntuPhone"
    readonly property var miniTimeout: 3000
    readonly property var defaultTimeout: 30000
    readonly property var longPollingTimeout: 10000
    readonly property var typingTimeout: 30000
    readonly property var borderColor: settings.darkmode ? UbuntuColors.jet : UbuntuColors.silk
    readonly property var version: "0.6.0"
    readonly property var downloadPath: "/home/phablet/.local/share/ubuntu-download-manager/fluffychat.christianpauly/Downloads/"
    readonly property var msg_status: { "SENDING": 0, "SENT": 1, "RECEIVED": 2, "SEEN": 3, "HISTORY": 4, "ERROR": -1 }

    /* =============================== GLOBAL VARIABLES ===============================

    This variables are accessable everywhere just with the variable names.
    */
    property var activeChat: null
    property var chatActive: false
    property var activeChatDisplayName: null
    property var activeChatTypingUsers: []
    property var activeUser: null
    property var progressBarRequests: 0
    property var waitingForSync: false
    property var appstatus: 4
    property var pushtoken: pushclient.token
    property var tabletMode: settings.token !== undefined && width > units.gu(90)
    property var prevMode: false
    property var mainStackWidth: mainStack.width
    property var generated_password: null
    property var desiredPhoneNumber: null
    property var consentUrl: ""
    property var consentContent: ""
    property var shareObject: null
    property var mainFontColor: settings.darkmode ? "#FFFFFF" : "#000000"


    /* =============================== LAYOUT ===============================

    The main page stack is the current layout of the app.
    */

    onTabletModeChanged: {
        if ( prevMode !== tabletMode ) {
            mainStack.clear ()
            if ( tabletMode ) mainStack.push( Qt.resolvedUrl("./pages/BlankPage.qml") )
            else if ( settings.token ) mainStack.push( Qt.resolvedUrl("./pages/ChatListPage.qml") )
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
        Component.onCompleted: push( Qt.resolvedUrl("./pages/ChatListPage.qml") )
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

    PageStack {
        id: mainStack
        anchors.fill: undefined
        anchors.right: parent.right
        anchors.top: parent.top
        width: tabletMode ? parent.width - units.gu(45) : parent.width
        function toStart () { while (depth > 1) pop() }
        height: parent.height
    }


    /* =============================== CONTROLLER ===============================

    All controller should be defined here. They are accessable everywhere by the
    id, defined here.
    */
    StorageController { id: storage }
    MatrixController { id: matrix }
    SenderController { id: sender }
    StampController { id: stamp }
    EventController { id: events }
    RoomNameController { id: roomnames }
    UserNameController { id: usernames }
    DisplayEventController { id: displayEvents }
    PushController { id: pushclient }
    MediaController { id: media }
    SettingsController { id: settings }
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
        property var downloadButton: null
        property var filename: null
        property var downloadUrl: null
        property var shareFunc: shareController.shareFile
    }
    Image {
        id: backgroundImage
        opacity: 0
        visible: settings.chatBackground !== undefined
        anchors.fill: mainStack
        source: settings.chatBackground
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



    /* =============================== CONNECTION MANAGER ===============================

    If the app suspend, then this will be triggered.
    */

    onActiveChatChanged: {
        roomnames.getById ( activeChat, function (name) {
            activeChatDisplayName = name
        } )
    }

    /* =============================== START POINT ===============================
    When the app starts, then this will be triggered!
    */
    Component.onCompleted: {
        storage.init ()
        matrix.init ()
    }
}
