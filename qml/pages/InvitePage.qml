import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/InvitePageActions.js" as PageActions

Page {
    anchors.fill: parent

    Component.onCompleted: PageActions.init ()

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
        id: header
        title: i18n.tr('Invite users')
        flickable: chatListView

        contents: TextField {
            id: searchField
            objectName: "searchField"
            property var searchMatrixId: false
            property var upperCaseText: displayText.toUpperCase()
            property var tempElement: null
            primaryItem: Icon {
                height: parent.height - units.gu(2)
                name: "find"
                anchors.left: parent.left
                anchors.leftMargin: units.gu(0.25)
            }
            width: parent.width - units.gu(2)
            anchors.centerIn: parent
            focus: true
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search e.g. @username:server.abc")
            onDisplayTextChanged: PageActions.search ()
        }
    }


    ListView {
        id: chatListView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        delegate: InviteListItem {}
        model: ListModel { id: model }
    }
}
