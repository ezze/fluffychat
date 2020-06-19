import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/UserDevicesPageActions.js" as PageActions
import "../components"

Page {
    anchors.fill: parent
    id: chatDevicesPage

    Component.onCompleted: PageActions.initChat ()

    header: PageHeader {
        id: header
        title: i18n.tr("Encryption settings")
    }

    ListModel { id: model }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        delegate: DeviceKeyListItem {}
        model: model
        clip: true
        section.property: "user"
        section.delegate: ListSeperator {
            text: section
        }
        header: SettingsListItem {
                id: initEncryption
                name: i18n.tr("(Needs Pantalaimon) Enable encryption")
                icon: "lock"
                onClicked: PageActions.initEncryption()
                visible: encryptionAlgorithm !== "" && canSendMessages
            }
    }

    Label {
        id: label
        text: loading ? i18n.tr("Loading…") : i18n.tr("No devices found")
        textSize: Label.Large
        color: UbuntuColors.graphite
        anchors.centerIn: parent
        visible: loading || model.count === 0
    }

}
