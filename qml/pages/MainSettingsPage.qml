import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Settings')

        trailingActionBar {
            actions: [
            Action {
                iconSource: matrix.onlineStatus ? "../../assets/online.svg" : "../../assets/offline.svg"
                onTriggered: {
                    matrix.get("/client/r0/pushers", null, function (m) { console.log(JSON.stringify(m))})
                    //matrix.get("/client/r0/pushrules/", null, function (m) { console.log(JSON.stringify(m))})
                }
            }
            ]
        }
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth

            SettingsListLink {
                name: i18n.tr("Notifications")
                icon: "notification"
                page: "NotificationSettingsPage"
            }

            SettingsListLink {
                name: i18n.tr("Account")
                icon: "account"
                page: "AccountSettingsPage"
            }

            SettingsListLink {
                name: i18n.tr("Theme")
                icon: "image-x-generic-symbolic"
                page: "ThemeSettingsPage"
            }

            SettingsListLink {
                name: i18n.tr("Security & Privacy")
                icon: "system-lock-screen"
                page: "PrivacySettingsPage"
            }

            SettingsListLink {
                name: i18n.tr("About")
                icon: "info"
                page: "InfoPage"
            }

        }
    }

}
