import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../pages"
import "../scripts/DefaultLayoutActions.js" as DefaultLayoutActions

AdaptivePageLayout {

    id: mainLayout
    anchors.fill: parent

    layouts: [
    PageColumnsLayout {
        when: width >= 3*defaultPageColumnWidth && chatActive
        // column #0
        PageColumn {
            minimumWidth: 0.5*defaultPageColumnWidth
            maximumWidth: 1.5*defaultPageColumnWidth
            preferredWidth: defaultPageColumnWidth
        }
        // column #1
        PageColumn {
            fillWidth: true
        }
        // column #2
        PageColumn {
            minimumWidth: 0.5*defaultPageColumnWidth
            maximumWidth: 1.5*defaultPageColumnWidth
            preferredWidth: defaultPageColumnWidth
        }
    },
    PageColumnsLayout {
        when: width >= 2*defaultPageColumnWidth
        // column #0
        PageColumn {
            minimumWidth: 0.5*defaultPageColumnWidth
            maximumWidth: 1.5*defaultPageColumnWidth
            preferredWidth: defaultPageColumnWidth
        }
        // column #1
        PageColumn {
            fillWidth: true
        }
    },
    PageColumnsLayout {
        when: true
        PageColumn {
            fillWidth: true
            minimumWidth: units.gu(10)
        }
    }
    ]

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
