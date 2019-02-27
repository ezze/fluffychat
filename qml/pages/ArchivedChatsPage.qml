import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/ArchivedChatsPageActions.js" as ArchivedChatsPageActions

StyledPage {
    anchors.fill: parent
    id: archivedChatListPage

    property var searching: true


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    Component.onCompleted: ArchivedChatsPageActions.update ()


    Connections {
        target: matrix
        onNewChatUpdate: ArchivedChatsPageActions.update ()
    }
    

    header: PageHeader {
        id: header
        title: i18n.tr("Archived chats")

        flickable: chatListView

        contents: TextField {
            id: searchField
            objectName: "searchField"
            primaryItem: Icon {
                height: parent.height - units.gu(2)
                name: "find"
                anchors.left: parent.left
                anchors.leftMargin: units.gu(0.25)
            }
            width: parent.width - units.gu(2)
            anchors.centerIn: parent
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search archived chats...")
        }
    }


    Label {
        id: loadingLabel
        anchors.centerIn: chatListView
        text: i18n.tr("There are no archived chats")
        visible: model.count === 0
    }


    ListView {
        id: chatListView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        delegate: ArchivedChatListItem {}
        model: ListModel { id: model }
    }
}
