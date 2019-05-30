import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/UserDevicesPageActions.js" as PageActions

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: JSON.parse(activeDevice.keys_json).unsigned.device_display_name || device.device_id
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }

        Label {
            width: parent.width
            text: PageActions.getDisplayPublicKey ()
            font.bold: true
            wrapMode: Text.WrapAnywhere
        }

        Button {
            text: i18n.tr("Verify")
            visible: !activeDevice.verified
            color: UbuntuColors.green
            onClicked: {
                PageActions.verify()
                PopupUtils.close(dialogue)
            }
        }
        Button {
            text: i18n.tr("Revoke verification")
            visible: activeDevice.verified
            color: UbuntuColors.red
            onClicked: {
                PageActions.revoke()
                PopupUtils.close(dialogue)
            }
        }
        Button {
            text: i18n.tr("Block device")
            visible: !activeDevice.blocked
            color: UbuntuColors.red
            onClicked: {
                PageActions.block()
                PopupUtils.close(dialogue)
            }
        }
        Button {
            text: i18n.tr("Unblock device")
            visible: activeDevice.blocked
            onClicked: {
                PageActions.unblock()
                PopupUtils.close(dialogue)
            }
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
