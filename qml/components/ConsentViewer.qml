import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2

BottomEdge {

    id: consentViewer
    height: parent.height

    readonly property string consentUrl

    onCollapseCompleted: {
        consentUrl = ""
        consentViewer.destroy ()
    }
    Component.onCompleted: commit()

    contentComponent: Page {
        height: consentViewer.height

        PageHeader {
            id: userHeader
            title: i18n.tr("Consent not given")
        }

        WebView {
            id: webview
            url: consentUrl
            width: parent.width
            height: parent.height - userHeader.height
            anchors.top: userHeader.bottom
        }
    }
}
