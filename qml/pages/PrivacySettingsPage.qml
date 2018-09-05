import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Security & Privacy')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth

            SettingsListSwitch {
                name: i18n.tr("Display 'I am typing' when I am typing")
                icon: "edit"
                onSwitching: function () { settings.sendTypingNotification = isChecked }
                Component.onCompleted: isChecked = settings.sendTypingNotification
            }

            SettingsListSwitch {
                name: i18n.tr("Automatically accept chat invitations")
                icon: "message-new"
                onSwitching: function () { settings.autoAcceptInvitations = isChecked }
                Component.onCompleted: isChecked = settings.autoAcceptInvitations
            }

            SettingsListLink {
                name: i18n.tr("Devices")
                icon: "phone-smartphone-symbolic"
                page: "DevicesSettingsPage"
            }

        }
    }
}
