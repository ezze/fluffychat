import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var ownPower
    property var canChangeAccessRules: false

    property var powerLevelDescription: ""
    property var activePowerLevel: ""

    Component.onCompleted: init ()

    Connections {
        target: events
        onNewEvent: update ( type, chat_id, eventType, eventContent )
    }

    function update ( type, chat_id, eventType, eventContent ) {
        if ( activeChat !== chat_id ) return
        var matchTypes = [ "m.room.power_levels", "m.room.member", "m.room.join_rules", "m.room.guest_access", "m.room.history_visibility" ]
        if ( matchTypes.indexOf( type ) !== -1 ) init ()
    }

    function init () {

        storage.transaction ( "SELECT power_level FROM Memberships WHERE chat_id='" + activeChat + "' AND matrix_id='" + matrix.matrixid + "'", function ( rs ) {
            ownPower = rs.rows[0].power_level

            // Get the member status of the user himself
            storage.transaction ( "SELECT * FROM Chats WHERE id='" + activeChat + "'", function (res) {

                join_rules.value = displayEvents.translate( res.rows[0].join_rules )
                history_visibility.value = displayEvents.translate( res.rows[0].history_visibility )
                guest_access.value = displayEvents.translate( res.rows[0].guest_access )

                canChangeAccessRules = ownPower >= res.rows[0].power_state_default
            })

        })


    }

    function powerlevelToIcon ( power_level ) {
        if ( power_level < 50 ) return "account"
        else if ( power_level < 100 ) return "cancel"
        else return "edit-clear"
    }

    header: FcPageHeader {
        title:  i18n.tr('Chat security & privacy settings')
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

            SettingsListItem {
                id: join_rules
                icon: "user-admin"
                name: i18n.tr('Who is allowed to join?')
                onClicked: canChangeAccessRules ? PopupUtils.open(changeJoinRulesDialog) : undefined
                rightIcon: canChangeAccessRules ? "settings" : ""
            }
            SettingsListItem {
                id: history_visibility
                icon: "stock_ebook"
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
            SettingsListLink {
                icon: "view-list-symbolic"
                name: i18n.tr('Chat permissions')
                page: "ChatPermissionsSettingsPage"
            }


        }
    }
}
