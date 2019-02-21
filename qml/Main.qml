import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.4
import "models"
import "components"
import "scripts/MatrixNames.js" as MatrixNames

/* =============================== MAIN.qml ===============================
This file is the start point of the app. It contains all important config variables,
instances of all controller, the layout (mainLayout) and the start point.
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
    readonly property var defaultPageColumnWidth: units.gu(50)

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
    property var tabletMode: matrix.token !== undefined && width > units.gu(90)
    property var prevMode: false
    property var desiredPhoneNumber: null
    property var desiredUsername: null
    property var consentUrl: ""
    property var consentContent: ""
    property var shareObject: null
    property var mainFontColor: settings.darkmode ? "#FFFFFF" : "#000000"
    property var mainBorderColor: settings.darkmode ? "#333333" : "#CCCCCC"
    property var bottomEdgeCommited: false


    /* =============================== LAYOUT ===============================

    The main page stack is the current layout of the app.
    */

    // Check if there are username, password and domain saved from a previous
    // session and autoconnect with them. If not, then just go to the login Page.

    MainLayout { id: mainLayout }



    /* =============================== MODELS ===============================

    All models should be defined here. They are accessable everywhere by the
    id, defined here.
    */
    StorageModel { id: storage }
    MatrixModel { id: matrix }
    PushModel { id: pushclient }
    SettingsModel { id: settings }
    UserMetricsModel { id: userMetrics }
    ContentHubModel { id: shareController }

    Toast { id: toast }
    ImageViewer { id: imageViewer }
    VideoPlayer { id: videoPlayer }
    LoadingScreen { id: loadingScreen }
    LockedScreen { id: lockedScreen }
    LoadingModal { id: loadingModal }
    Audio { id: audio }
    ConfirmDialog { id: confirmDialog }
    UserSettingsDialog { id: userSettingsDialog }
    DownloadDialog {
        id: downloadDialog
        property var current: null
        property var filename: null
        property var downloadUrl: null
        property var shareFunc: 0
    }
    Image {
        id: backgroundImage
        opacity: chatActive
        visible: settings.chatBackground !== undefined
        anchors.fill: mainLayout
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


    /* =============================== CONNECTION MANAGER ===============================

    If the app suspend, then this will be triggered.
    */

    onActiveChatChanged: {
        if ( activeChat === null ) return
        MatrixNames.getChatAvatarById ( activeChat, function (name) {
            activeChatDisplayName = name
        } )
    }
}
