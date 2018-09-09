import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var ownPower
    property var canChangeAccessRules: false
    property var canChangePermissions: false

    property var powerLevelDescription: ""
    property var activePowerLevel: ""

    Component.onCompleted: init ()

    Connections {
        target: events
        onChatTimelineEvent: init ()
    }

    function init () {

        storage.transaction ( "SELECT power_level FROM Memberships WHERE chat_id='" + activeChat + "' AND matrix_id='" + matrix.matrixid + "'", function ( rs ) {
            ownPower = rs.rows[0].power_level

            // Get the member status of the user himself
            storage.transaction ( "SELECT * FROM Chats WHERE id='" + activeChat + "'", function (res) {

                join_rules.value = displayEvents.translate( res.rows[0].join_rules )
                if ( res.rows[0].join_rules === "public" ) join_rules.icon = "private-browsing-exit"
                else if ( res.rows[0].join_rules === "private" ) join_rules.icon = "private-browsing"
                else if ( res.rows[0].join_rules === "knock" ) join_rules.icon = "help"
                else if ( res.rows[0].join_rules === "invite" ) join_rules.icon = "private-tab-new"
                history_visibility.value = displayEvents.translate( res.rows[0].history_visibility )
                if ( res.rows[0].history_visibility === "shared" ) history_visibility.icon = "private-browsing-exit"
                else if ( res.rows[0].history_visibility === "invited" ) history_visibility.icon = "private-tab-new"
                else if ( res.rows[0].history_visibility === "joined" ) history_visibility.icon = "private-browsing"
                guest_access.value = displayEvents.translate( res.rows[0].guest_access )
                if ( res.rows[0].guest_access === "can_join" ) guest_access.icon = "private-browsing-exit"
                else if ( res.rows[0].guest_access === "forbidden" ) guest_access.icon = "private-browsing"

                power_events_default.value = usernames.powerlevelToStatus ( res.rows[0].power_events_default )
                power_events_default.icon = powerlevelToIcon ( res.rows[0].power_events_default )
                power_state_default.value = usernames.powerlevelToStatus ( res.rows[0].power_state_default )
                power_state_default.icon = powerlevelToIcon ( res.rows[0].power_state_default )
                power_redact.value = usernames.powerlevelToStatus ( res.rows[0].power_redact )
                power_redact.icon = powerlevelToIcon ( res.rows[0].power_redact )
                power_invite.value = usernames.powerlevelToStatus ( res.rows[0].power_invite )
                power_invite.icon = powerlevelToIcon ( res.rows[0].power_invite )
                power_ban.value = usernames.powerlevelToStatus ( res.rows[0].power_ban )
                power_ban.icon = powerlevelToIcon ( res.rows[0].power_ban )
                power_kick.value = usernames.powerlevelToStatus ( res.rows[0].power_kick )
                power_kick.icon = powerlevelToIcon ( res.rows[0].power_kick )
                power_user_default.value = usernames.powerlevelToStatus ( res.rows[0].power_user_default )
                power_user_default.icon = powerlevelToIcon ( res.rows[0].power_user_default )
                power_event_avatar.value = usernames.powerlevelToStatus ( res.rows[0].power_event_avatar )
                power_event_avatar.icon = powerlevelToIcon ( res.rows[0].power_event_avatar )
                power_event_history_visibility.value = usernames.powerlevelToStatus ( res.rows[0].power_event_history_visibility )
                power_event_history_visibility.icon = powerlevelToIcon ( res.rows[0].power_event_history_visibility )
                power_event_canonical_alias.value = usernames.powerlevelToStatus ( res.rows[0].power_event_canonical_alias )
                power_event_canonical_alias.icon = powerlevelToIcon ( res.rows[0].power_event_canonical_alias )
                power_event_aliases.value = usernames.powerlevelToStatus ( res.rows[0].power_event_canonical_alias )
                power_event_aliases.icon = powerlevelToIcon ( res.rows[0].power_event_aliases )
                power_event_name.value = usernames.powerlevelToStatus ( res.rows[0].power_event_name )
                power_event_name.icon = powerlevelToIcon ( res.rows[0].power_event_name )
                power_event_power_levels.value = usernames.powerlevelToStatus ( res.rows[0].power_event_power_levels )
                power_event_power_levels.icon = powerlevelToIcon ( res.rows[0].power_event_power_levels )

                canChangeAccessRules = ownPower >= res.rows[0].power_state_default
                canChangePermissions = ownPower >= res.rows[0].power_event_power_levels

                console.log("OwnPower:", ownPower, " Power for changing accessrules: ", res.rows[0].power_state_default)
            })

        })


    }

    function powerlevelToIcon ( power_level ) {
        if ( power_level < 50 ) return "account"
        else if ( power_level < 100 ) return "cancel"
        else return "edit-clear"
    }

    header: FcPageHeader {
        title:  i18n.tr('Security & Privacy') + " - " + activeChatDisplayName
    }

    ChangeJoinRulesDialog { id: changeJoinRulesDialog }
    ChangeHistoryVisibilityDialog { id: changeHistoryVisibilityDialog }
    ChangeGuestAccessDialog { id: changeGuestAccessDialog }
    ChangePowerLevelDialog { id: changePowerLevelDialog }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth


            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }

            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Access rules:")
                font.bold: true
            }

            SettingsListItem {
                id: join_rules
                icon: "private-browsing"
                name: i18n.tr('Who is allowed to join?')
                onClicked: canChangeAccessRules ? PopupUtils.open(changeJoinRulesDialog) : undefined
                rightIcon: canChangeAccessRules ? "settings" : ""
            }
            SettingsListItem {
                id: history_visibility
                icon: "private-browsing"
                name: i18n.tr('Who can see the chat history?')
                onClicked: canChangeAccessRules ? PopupUtils.open(changeHistoryVisibilityDialog) : undefined
                rightIcon: canChangeAccessRules ? "settings" : ""
            }
            SettingsListItem {
                id: guest_access
                icon: "private-browsing"
                name: i18n.tr('Guest access?')
                onClicked: canChangeAccessRules ? PopupUtils.open(changeGuestAccessDialog) : undefined
                rightIcon: canChangeAccessRules ? "settings" : ""
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }

            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Permissions:")
                font.bold: true
            }

            SettingsListItem {
                id: power_events_default
                name: i18n.tr('Who can send messages?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "events_default"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_state_default
                name: i18n.tr('Who can configure this chat?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "state_default"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_redact
                name: i18n.tr('Who can remove messages?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "redact"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_invite
                name: i18n.tr('Who can invite users?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "invite"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_ban
                name: i18n.tr('Who can ban users?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "ban"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_kick
                name: i18n.tr('Who can kick users?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "kick"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_event_name
                name: i18n.tr('Who can change the chat name?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "m.room.name"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_event_avatar
                name: i18n.tr('Who can change the chat avatar?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "m.room.avatar"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_event_history_visibility
                name: i18n.tr('Who can change the chat history visibility?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "m.room.history_visibility"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_event_aliases
                name: i18n.tr('Who can change the chat addresses?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "m.room.aliases"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_event_canonical_alias
                name: i18n.tr('Who can change the canonical chat alias?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "m.room.canonical_alias"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_event_power_levels
                name: i18n.tr('Who can change the user permissions?')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "m.room.power_levels"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }
            SettingsListItem {
                id: power_user_default
                name: i18n.tr('Default user permissions:')
                rightIcon: canChangePermissions ? "settings" : ""
                onClicked: function () {
                    if ( canChangeAccessRules ) {
                        activePowerLevel = "users_default"
                        powerLevelDescription = name
                        PopupUtils.open(changePowerLevelDialog)
                    }
                }
            }

        }
    }
}
