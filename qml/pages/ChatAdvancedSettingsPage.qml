import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/ChatAdvancedSettingsPageActions.js" as PageActions

Page {
    id: chatPrivacySettingsPage
    anchors.fill: parent

    property var ownPower
    property var canChangePermissions: false
    property var canChangeAccessRules: false
    property var canChangeHistoryRules: false

    property var powerLevelDescription: ""
    property var activePowerLevel: ""

    Component.onCompleted: PageActions.init ()

    Connections {
        target: matrix
        onNewEvent: PageActions.update ( type, chat_id, eventType, eventContent )
    }

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
        title:  i18n.tr('Advanced settings')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: chatPrivacySettingsPage.width

            ListSeperator {
                text: i18n.tr("Access")
            }

            SettingsListSwitch {
                id: invitedAllowed
                name: i18n.tr("Users can be invited")
                icon: "contact-new"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeAccessRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchInvitedAllowed( isChecked )
            }

            SettingsListSwitch {
                id: chatIsPublic
                name: i18n.tr("Chat is public accessible")
                icon: "lock-broken"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeAccessRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchChatIsPublic( isChecked )
            }

            SettingsListSwitch {
                id: guestsAllowed
                name: i18n.tr("Guest users are allowed")
                icon: "private-browsing"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeAccessRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchGuestsAllowed ()
            }

            SettingsListLink {
                name: i18n.tr("Public chat addresses")
                icon: "stock_link"
                page: "ChatAliasSettingsPage"
                sourcePage: chatPrivacySettingsPage
            }

            ListSeperator {
                text: i18n.tr("History visibility")
            }

            SettingsListSwitch {
                id: invitedHistoryAccess
                name: i18n.tr("History is visible from invitation")
                icon: "user-admin"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeHistoryRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchInvitedHistoryAccess ( isChecked )
            }
            SettingsListSwitch {
                id: sharedHistoryAccess
                name: i18n.tr("Members can access full chat history")
                icon: "stock_ebook"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeHistoryRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchSharedHistoryAccess ( isChecked )
            }
            SettingsListSwitch {
                id: worldHistoryAccess
                name: i18n.tr("Anyone can access full chat history")
                icon: "stock_website"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeHistoryRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchWorldHistoryAccess ()
            }

            ListSeperator {
                text: i18n.tr("Chat permissions")
            }

            SettingsListItem {
                id: power_events_default
                name: i18n.tr('Who can send messages?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "events_default", name )
            }
            SettingsListItem {
                id: power_state_default
                name: i18n.tr('Who can configure this chat?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "state_default", name )
            }
            SettingsListItem {
                id: power_redact
                name: i18n.tr('Who can remove messages?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "redact", name )
            }
            SettingsListItem {
                id: power_invite
                name: i18n.tr('Who can invite users?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "invite", name )
            }
            SettingsListItem {
                id: power_ban
                name: i18n.tr('Who can ban users?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "ban", name )
            }
            SettingsListItem {
                id: power_kick
                name: i18n.tr('Who can kick users?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "kick", name )
            }
            SettingsListItem {
                id: power_event_name
                name: i18n.tr('Who can change the chat name?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "m.room.name", name )
            }
            SettingsListItem {
                id: power_event_avatar
                name: i18n.tr('Who can change the chat avatar?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "m.room.avatar", name )
            }
            SettingsListItem {
                id: power_event_history_visibility
                name: i18n.tr('Who can change the chat history visibility?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "m.room.history_visibility", name )
            }
            SettingsListItem {
                id: power_event_aliases
                name: i18n.tr('Who can change the chat addresses?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "m.room.aliases", name )
            }
            SettingsListItem {
                id: power_event_canonical_alias
                name: i18n.tr('Who can change the canonical chat alias?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "m.room.canonical_alias", name )
            }
            SettingsListItem {
                id: power_event_power_levels
                name: i18n.tr('Who can change the user permissions?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "m.room.power_levels", name )
            }
            SettingsListItem {
                id: power_user_default
                name: i18n.tr('Default user permissions:')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: PageActions.changePermission ( "users_default", name )
            }
        }
    }

    ActionSelectionPopover {
        id: contextualActions
        z: 10
        actions: ActionList {
            Action {
                text: i18n.tr("Members")
                onTriggered: PageActions.changePowerLevel ( 0 )
            }
            Action {
                text: i18n.tr("Moderators")
                onTriggered: PageActions.changePowerLevel ( 50 )
            }
            Action {
                text: i18n.tr("Admins")
                onTriggered: PageActions.changePowerLevel ( 99 )
            }
            Action {
                text: i18n.tr("Owner")
                onTriggered: PageActions.changePowerLevel ( 100 )
            }
        }
    }
}
