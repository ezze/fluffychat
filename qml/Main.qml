import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.4
import Qt.labs.settings 1.0
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

    width: units.gu(125)
    height: units.gu(75)
    Settings {
        property alias width: root.width
        property alias height: root.height
    }
    theme: ThemeSettings {
        name: mainLayout.darkmode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"
    }

    /* =============================== CONFIG VARIABLES ===============================

    This config variables are readonly!
    */
    readonly property var defaultDomain: "ubports.chat"
    readonly property var defaultIDServer: "vector.im"
    readonly property var version: "11.9"
    readonly property var downloadPath: "/home/phablet/.local/share/ubuntu-download-manager/fluffychat.christianpauly/Downloads/"
    readonly property var msg_status: { "SENDING": 0, "SENT": 1, "RECEIVED": 2, "SEEN": 3, "HISTORY": 4, "ERROR": -1 }
    readonly property var platforms: { "UBPORTS": "Ubuntu Touch", "LINUX": "Linux" }

    /* =============================== GLOBAL VARIABLES ===============================

    This variables are accessable everywhere just with the variable names.
    */
    property var activeChat: null
    property var chatActive: false
    property var activeUser: null
    property var desiredPhoneNumber: null
    property var desiredUsername: null
    property var activeChatDisplayName: null
    property var activeChatTypingUsers: []
    property var activeChatMembers: []
    property string pushToken: ""
    property string platform: {
        if (pushClient.status === Loader.Error) return platforms.LINUX
        else return platforms.UBPORTS
    }
    property bool mobileMode: platform === platforms.UBPORTS
    property string deviceName: "FluffyChat %1".arg(platform)


    /* =============================== LAYOUT ===============================

    The main page stack is the current layout of the app.
    */

    // Check if there are username, password and domain saved from a previous
    // session and autoconnect with them. If not, then just go to the login Page.

    MainLayout { id: mainLayout }
    BottomEdgePageStack { id: bottomEdgePageStack}

    ProgressBar {
        id: requestProgressBar
        indeterminate: true
        width: parent.width
        anchors.top: parent.top
        visible: matrix.waitingForAnswer > 0 || !indeterminate
        maximumValue: 100
        z: 10
    }

    Toast { id: toast }
    ImageViewer { id: imageViewer }
    LockedScreen { id: lockedScreen }
    Audio { id: audio }
    ConfirmDialog { id: confirmDialog }
    property var firstSMSSid: null
    property var firstSMSClientSecret: null
    EnterFirstSMSTokenDialog { id: enterFirstSMSToken }
    DownloadDialog {
        id: downloadDialog
        property var current: null
        property var filename: null
        property var downloadUrl: null
        property var shareFunc: 0
    }
    function download( filename, downloadUrl, shareFunc ) {
        if ( platform === platforms.UBPORTS ) {
            downloadDialog.filename = filename
            downloadDialog.downloadUrl = downloadUrl
            downloadDialog.shareFunc = shareFunc
            downloadDialog.current = PopupUtils.open(downloadDialog)
        }
        else Qt.openUrlExternally( downloadUrl )
    }
    Image {
        id: backgroundImage
        opacity: chatActive
        visible: mainLayout.chatBackground !== undefined
        anchors.fill: mainLayout
        source: mainLayout.chatBackground || ""
        cache: true
        fillMode: Image.PreserveAspectCrop
        z: -1
        onStatusChanged: if (status == Image.Error) mainLayout.chatBackground = undefined
    }

    // Simple universal confirmation dialog
    property var confirmDialogText: i18n.tr("Are you sure?")
    property var confirmDialogFunction: function () {}
    function showConfirmDialog ( text, action ) {
        confirmDialogText = text
        confirmDialogFunction = action
        PopupUtils.open( confirmDialog )
    }



    /* =============================== MODELS ===============================
    All models should be defined here. They are accessable everywhere by the
    id, defined here.
    */
    StorageModel { id: storage }
    MatrixModel {
        id: matrix
        onReqError: toast.show ( error )
        onReseted: mainLayout.init ()
        onShowConsentUrl: {
            var openUrlFunction = function () {
                Qt.openUrlExternally ( url )
            }
            showConfirmDialog ( i18n.tr("You must agree to the privacy policy"), openUrlFunction )
        }
    }
    Loader {
        id: connectivity
        source: Qt.resolvedUrl("./components/CustomConnectivity.qml")
    }
    Loader {
        id: pushClient
        source: Qt.resolvedUrl("./models/PushModel.qml")
    }
    signal dismissNotification (string tag)
    UserMetricsModel { id: userMetrics }
    ContentHubModel {
        id: contentHub
        onCopiedToClipboard: toast.show( i18n.tr("Copied to the clipboard") )
    }


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
