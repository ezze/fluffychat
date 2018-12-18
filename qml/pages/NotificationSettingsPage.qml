import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

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
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.suppress_notices" ) {
                        mrule_suppress_notices.isChecked = !response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.invite_for_me" ) {
                        mrule_invite_for_me.isChecked = response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.member_event" ) {
                        mrule_member_event.isChecked = response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.contains_display_name" ) {
                        mrule_contains_display_name.isChecked = response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.contains_user_name" ) {
                        mrule_contains_user_name.isChecked = response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.call" ) {
                        mrule_call.isChecked = response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.room_one_to_one" ) {
                        mrule_room_one_to_one.isChecked = response.global[type][i].enabled
                    }
                    else if ( response.global[type][i].rule_id === ".m.rule.message" ) {
                        mrule_message.isChecked = response.global[type][i].enabled
                    }


                }
            }

            notificationSettingsList.enabled = true

        } );
    }

    header: FcPageHeader {
        title: i18n.tr('Notifications')
    }

    ScrollView {

        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth
            id: notificationSettingsList
            property var enabled: false
            opacity: enabled ? 1 : 0.5

            SettingsListSwitch {
                name: i18n.tr("Enable notifications")
                id: mrule_master
                icon: "audio-volume-muted"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.master", !isChecked, "override" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Common messages")
                id: mrule_message
                icon: "message"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.message", isChecked, "underride" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Messages from single chats")
                id: mrule_room_one_to_one
                icon: "contact"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.room_one_to_one", isChecked, "underride" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Contains my display name")
                id: mrule_contains_display_name
                icon: "crop"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.contains_display_name", isChecked, "override" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Contains my user name")
                id: mrule_contains_user_name
                icon: "account"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.contains_user_name", isChecked, "default" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Invitations for me")
                id: mrule_invite_for_me
                icon: "contact-new"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.invite_for_me", isChecked, "override" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Chat members change")
                id: mrule_member_event
                icon: "contact-group"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.member_event", isChecked, "override" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Incoming VOIP calls")
                id: mrule_call
                icon: "incoming-call"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.call", isChecked, "underride" )
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Messages from bots")
                id: mrule_suppress_notices
                icon: "computer-symbolic"
                isEnabled: notificationSettingsList.enabled
                onSwitching: function () {
                    if ( isEnabled ) changeRule ( ".m.rule.suppress_notices", !isChecked, "override" )
                }
            }

            SettingsListLink {
                name: i18n.tr("Targets")
                icon: "phone-smartphone-symbolic"
                page: "NotificationTargetSettingsPage"
            }

            Component.onCompleted: getRules ()

        }
    }
}
