import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/ChatAliasSettingsPageActions.js" as ChatAliasSettingsPageActions

StyledPage {
    anchors.fill: parent

    property var canEditAddresses: false
    property var canEditCanonicalAlias: false
    property var addresses: []


    Component.onCompleted: ChatAliasSettingsPageActions.init ()

    Connections {
        target: matrix
        onNewEvent: ChatAliasSettingsPageActions.update ( type, chat_id, eventType, eventContent )
    }

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
        id: header
        title:  i18n.tr('Public chat addresses')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "insert-link"
                text: i18n.tr("Add chat address")
                onTriggered: PopupUtils.open( addAliasDialog )
                visible: canEditAddresses
            }
            ]
        }
    }

    AddAliasDialog { id: addAliasDialog }

    ListView {
        id: addressesList
        anchors.top: header.bottom
        width: parent.width
        height: root.height / 1.5
        delegate: AddressesListItem { }
        model: ListModel { id: model }
    }

}
