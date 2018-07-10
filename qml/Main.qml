import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
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
    readonly property var defaultMainColor: "#5625BA"
    readonly property var defaultDomain: "matrix.org"
    readonly property var defaultDeviceName: "UbuntuPhone"
    readonly property var miniTimeout: 3000
    readonly property var defaultTimeout: 30000
    readonly property var longPollingTimeout: 10000
    readonly property var typingTimeout: 30000
    readonly property var borderColor: settings.darkmode ? UbuntuColors.jet : UbuntuColors.silk
    readonly property var version: "0.3.1"

    /* =============================== GLOBAL VARIABLES ===============================

    This variables are accessable everywhere just with the variable names.
    */
    property var activeChat: null
    property var activeChatDisplayName: null
    property var activeChatTypingUsers: []
    property var progressBarRequests: 0
    property var waitingForSync: false
    property var appstatus: 4
    property var pushtoken: pushclient.token


    /* =============================== LAYOUT ===============================

    The main page stack is the current layout of the app.
    */

    ProgressBar {
        id: requestProgressBar
        indeterminate: true
        width: parent.width
        anchors.top: parent.top
        visible: progressBarRequests > 0
        z: 10
    }

    PageStack {
        id: mainStack
        function toStart () { while (depth > 1) pop() }
    }


    /* =============================== CONTROLLER ===============================

    All controller should be defined here. They are accessable everywhere by the
    id, defined here.
    */
    StorageController { id: storage }
    MatrixController { id: matrix }
    StampController { id: stamp }
    EventController { id: events }
    RoomNameController { id: roomnames }
    UserNameController { id: usernames }
    DisplayEventController { id: displayEvents }
    PushController { id: pushclient }
    MediaController { id: media }
    SettingsController { id: settings }
    Toast { id: toast }
    LoadingModal { id: loadingModal }


    /* =============================== CONNECTION MANAGER ===============================

    If the app suspend, then this will be triggered.
    */
    Connections {
        target: Qt.application
        //onStateChanged: if(Qt.application.state === Qt.ApplicationActive) events.restartSync ()
    }

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
