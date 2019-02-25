import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

StyledPage {
    id: notificationTargetPage
    anchors.fill: parent

    property var currentTarget

    function changeRule ( rule_id, enabled, type ) {
        console.log( notificationSettingsList.enabled )
        if ( notificationSettingsList.enabled ) {
            notificationSettingsList.enabled = false
            matrix.put ( "/client/r0/pushrules/global/%1/%2/enabled".arg(type).arg(rule_id), {"enabled": enabled}, getRules )
        }
    }

    function getRules () {
        matrix.get( "/client/r0/pushrules/", null, function ( response ) {

            notificationSettingsList.enabled = false

            for ( var type in response.global ) {
                for ( var i = 0; i < response.global[type].length; i++ ) {
                    if ( response.global[type][i].rule_id === ".m.rule.master" ) {
                        mrule_master.isChecked = !response.global[type][i].enabled
                        break
                    }
                }
            }

            notificationSettingsList.enabled = true

        } );
    }

    function getTargets () {
        matrix.get ( "/client/r0/pushers", null, function ( response ) {
            targetList.children = ""
            for ( var i = 0; i < response.pushers.length; i++ ) {
                var newListItem = Qt.createComponent("../components/TargetListItem.qml")
                newListItem.createObject(targetList, { target: response.pushers[i] } )
            }
        })
    }


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
                    if ( isEnabled ) changeRule ( ".m.rule.master", !isChecked, "override" )
                }
                Component.onCompleted: getRules ()
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

                Component.onCompleted: getTargets ()
            }
        }

    }



    TargetInfoDialog { id: targetInfoDialog }
}
