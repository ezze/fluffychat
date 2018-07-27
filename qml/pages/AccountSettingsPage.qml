import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Account')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth

            SettingsListItem {
                name: i18n.tr("Change display name")
                icon: "edit"
                onClicked: PopupUtils.open(displaynameDialog)
            }

            SettingsListItem {
                name: i18n.tr("Change password")
                icon: "lock"
                onClicked: PopupUtils.open(passwordDialog)
            }

            SettingsListItem {
                name: i18n.tr("Disable account")
                icon: "edit-delete"
                onClicked: PopupUtils.open(accountDialog)
            }

            SettingsListItem {
                name: i18n.tr("Logout")
                icon: "system-shutdown"
                onClicked: PopupUtils.open(logoutDialog)
            }
        }
    }

    ChangeDisplaynameDialog { id: displaynameDialog }
    ChangePasswordDialog { id: passwordDialog }
    DisableAccountDialog { id: accountDialog }
    LogoutDialog { id: logoutDialog }
}
