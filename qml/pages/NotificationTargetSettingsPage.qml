import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/NotificationTargetSettingsPageActions.js" as PageStack

Page {
    id: notificationTargetPage
    anchors.fill: parent

    property var currentTarget

    header: PageHeader {
        title: i18n.tr('Notification settings')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: scrollView.width
            id: notificationSettingsList
            property var enabled: false

            SettingsListSwitch {
                name: i18n.tr("Enable notifications")
                id: mrule_master
                icon: "audio-volume-high"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) PageActions.changeRule ( ".m.rule.master", !isChecked, "override" )
                }
                Component.onCompleted: PageActions.getRules ()
            }

            SettingsListLink {
                name: i18n.tr("Advanced notification settings")
                icon: "filters"
                page: "NotificationSettingsPage"
                sourcePage: notificationTargetPage
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: Qt.rgba(0,0,0,0)
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: Qt.rgba(0,0,0,0)
                Label {
                    height: units.gu(2)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("Devices that receive push notifications:")
                    font.bold: true
                }
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: Qt.rgba(0,0,0,0)
            }

            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.ash
            }


            Column {
                width: parent.width
                id: targetList

                Component.onCompleted: PageActions.getTargets ()
            }
        }
    }
    TargetInfoDialog { id: targetInfoDialog }
}
