import QtQuick 2.9
import Ubuntu.Components 1.3
import UserMetrics 0.1
import Qt.labs.settings 1.0
import "../scripts/MatrixNames.js" as MatrixNames

/*============================= USERMETRICS CONTROLLER ============================
*/

Item {

    property alias sentMessages: userMetricsSettings.sentMessages
    onSentMessagesChanged: metrics.update(0)

    Settings {
        id: userMetricsSettings
        property var sentMessages: 0
    }

    Metric {
        id: metrics
        name: Qt.application.name
        format: i18n.tag("Hey %1! 🤗 You have sent %2 FluffyChat messages from your Ubuntu Touch device today. ❤").arg( MatrixNames.transformFromId(matrix.matrixid) ).arg(sentMessages)
        emptyFormat: i18n.tag("Hey %1! 🤗 You have sent no FluffyChat messages from your Ubuntu Touch device today. ❤").arg( MatrixNames.transformFromId(matrix.matrixid) )
        domain: "christianpauly.fluffychat"
    }
}
