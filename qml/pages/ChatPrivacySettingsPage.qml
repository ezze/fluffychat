import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    Component.onCompleted: init ()

    Connections {
        target: events
        onChatTimelineEvent: init ()
    }

    function init () {

        // Get the member status of the user himself
        storage.transaction ( "SELECT * FROM Chats WHERE id='" + activeChat + "'", function (res) {
            join_rules.value = displayEvents.translate( res.rows[0].join_rules )
            history_visibility.value = displayEvents.translate( res.rows[0].history_visibility )
            guest_access.value = displayEvents.translate( res.rows[0].guest_access )
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
            power_event_name.value = usernames.powerlevelToStatus ( res.rows[0].power_event_name )
            power_event_name.icon = powerlevelToIcon ( res.rows[0].power_event_name )
            power_event_power_levels.value = usernames.powerlevelToStatus ( res.rows[0].power_event_power_levels )
            power_event_power_levels.icon = powerlevelToIcon ( res.rows[0].power_event_power_levels )
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
                icon: "user-admin"
                name: i18n.tr('Who is allowed to join?')
            }
            SettingsListItem {
                id: history_visibility
                icon: "sort-listitem"
                name: i18n.tr('Who can see the chat history?')
            }
            SettingsListItem {
                id: guest_access
                icon: "contact-group"
                name: i18n.tr('Guest access?')
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
            }
            SettingsListItem {
                id: power_state_default
                name: i18n.tr('Who can configure this chat?')
            }
            SettingsListItem {
                id: power_redact
                name: i18n.tr('Who can remove messages?')
            }
            SettingsListItem {
                id: power_invite
                name: i18n.tr('Who can invite users?')
            }
            SettingsListItem {
                id: power_ban
                name: i18n.tr('Who can ban users?')
            }
            SettingsListItem {
                id: power_kick
                name: i18n.tr('Who can kick users?')
            }
            SettingsListItem {
                id: power_event_name
                name: i18n.tr('Who can change the chat name?')
            }
            SettingsListItem {
                id: power_event_avatar
                name: i18n.tr('Who can change the chat avatar?')
            }
            SettingsListItem {
                id: power_event_history_visibility
                name: i18n.tr('Who can change the chat history visibility?')
            }
            SettingsListItem {
                id: power_event_canonical_alias
                name: i18n.tr('Who can change the canonical chat alias?')
            }
            SettingsListItem {
                id: power_event_power_levels
                name: i18n.tr('Who can change the user permissions?')
            }
            SettingsListItem {
                id: power_user_default
                name: i18n.tr('Default user permissions:')
            }

        }
    }
}
