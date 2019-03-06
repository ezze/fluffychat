import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/PhoneSettingsPageActions.js" as PageActions

Page {
    anchors.fill: parent
    id: phoneSettingsPage

    property var client_secret
    property var sid


    Component.onCompleted: PageActions.sync ()


    header: PageHeader {
        id: header
        title:  i18n.tr('Connected phone numbers')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "add"
                text: i18n.tr("Add phone number")
                onTriggered: PopupUtils.open( addPhoneDialog )
            }
            ]
        }
    }

    AddPhoneDialog { id: addPhoneDialog }
    EnterSMSTokenDialog { id: enterSMSToken }

    Label {
        anchors.centerIn: addressesList
        text: i18n.tr("No phone numbers connected")
        visible: model.count === 0
    }

    ListView {
        id: addressesList
        anchors.top: header.bottom
        width: parent.width
        height: parent.height - header.height
        delegate: PhoneListItem { }
        model: ListModel { id: model }
        z: -1
    }

}
