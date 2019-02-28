import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"
import "../scripts/NotificationChatSettingsPageActions.js" as PageActions

Page {
    id: notificationChatSettingsPage
    anchors.fill: parent

    Component.onCompleted: PageActions.updateView ()

    property var status: 0

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
        title: i18n.tr('Notifications')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: notificationChatSettingsPage.width
            SettingsListItem {
                name: i18n.tr("Notify")
                Icon {
                    id: "notify"
                    visible: status === 3
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-high"
                onClicked: PageActions.setNotify ()
            }
            SettingsListItem {
                name: i18n.tr("Only if mentioned")
                Icon {
                    id: "mentioned"
                    visible: status === 2
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-low"
                onClicked: PageActions.setOnlyMentions ()
            }
            SettingsListItem {
                name: i18n.tr("Don't notify")
                Icon {
                    id: "dont_notify"
                    visible: status === 1
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-muted"
                onClicked: PageActions.setMuted ()
            }
        }
    }
}
