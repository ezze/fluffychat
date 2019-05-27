import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        property var device
        title: i18n.tr("Unknown device")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }

        Label {
            text: device.keys
        }

        Button {
            text: i18n.tr("Verify")
            visible: !device.verified
            color: UbuntuColors.green
        }
        Button {
            text: i18n.tr("Revoke verification")
            visible: device.verified
            color: UbuntuColors.red
        }
        Button {
            text: i18n.tr("Block device")
            visible: !device.blocked
            color: UbuntuColors.red
        }
        Button {
            text: i18n.tr("Unblock device")
            visible: device.verified
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
