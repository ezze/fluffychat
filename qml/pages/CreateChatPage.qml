import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/CreateChatPageActions.js" as PageActions

Page {
    id: createChatPage
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr('Add Chat')

        trailingActionBar {
            actions: [
            Action {
                id: newContactAction
                iconName: "contact-new"
                text: i18n.tr("Import from addressbook")
                onTriggered: PopupUtils.open(addContactDialog)
            }
            ]
        }

        contents: TextField {
            id: searchField
            objectName: "searchField"
            property var searchMatrixId: false
            property var upperCaseText: displayText.toUpperCase()
            primaryItem: Icon {
                height: parent.height - units.gu(2)
                name: "find"
                anchors.left: parent.left
                anchors.leftMargin: units.gu(0.25)
            }
            width: parent.width - units.gu(2)
            anchors.centerIn: parent
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Filter contacts")
        }
    }

    Connections {
        target: matrix
        //onNewEvent: PageActions.updatePresence ( type, chat_id, eventType, eventContent )
    }

    Connections {
        target: bottomEdge
        onCommitCompleted: PageActions.update ()
        onCollapseCompleted: model.clear()
    }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        delegate: ContactListItem {}
        model: ListModel { id: model }
        section.property: "medium"
        section.delegate: ListSeperator { text: PageActions.medium2Section(section) }

        header: Rectangle {
            width: chatListView.width
            height: settingsListFooter.height * 2
            SettingsListFooter {
                id: settingsListFooter
                icon: "contact-group"
                name: i18n.tr("New group")
                iconWidth: units.gu(4)
                onClicked: PageActions.createNewGroup ()
                anchors.top: parent.top
            }
            SettingsListFooter {
                icon: "find"
                name: i18n.tr("Public groups")
                iconWidth: units.gu(4)
                onClicked: bottomEdgePageStack.push ( Qt.resolvedUrl("./DiscoverPage.qml") )
                anchors.bottom: parent.bottom
            }
        }
    }

    Label {
        text: i18n.tr("Click on the top right button to add contacts.")
        textSize: Label.Large
        color: UbuntuColors.graphite
        anchors.centerIn: chatListView
        width: parent.width - units.gu(4)
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        wrapMode: Text.Wrap
        visible: model.count === 0
        z: -1
    }

    ContactImport {
        id: contactImport
        onImportCompleted: PageActions.update ()
    }

    AddContactDialog { id: addContactDialog }

}
