import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../pages"
import "../scripts/DefaultLayoutActions.js" as DefaultLayoutActions

AdaptivePageLayout {

    id: mainLayout

    anchors.fill: parent

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

    primaryPageSource: Qt.resolvedUrl( DefaultLayoutActions.getPrimaryPage () )

    signal init ()
    signal toChat ( var chatID )

    onInit: DefaultLayoutActions.init ()
    onToChat: DefaultLayoutActions.toChat ( chatID )
}
