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
        storage.transaction ( "SELECT guest_access, history_visibility, join_rules FROM Chats WHERE id='" + activeChat + "'", function (res) {
            join_rules.value = displayEvents.translate( res.rows[0].join_rules )
            history_visibility.value = displayEvents.translate( res.rows[0].history_visibility )
            guest_access.value = displayEvents.translate( res.rows[0].guest_access )
        })
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

            SettingsListItem {
                id: join_rules
                icon: "user-admin"
                name: i18n.tr('Who is allowed to join?')
                value: ""
            }
            SettingsListItem {
                id: history_visibility
                icon: "sort-listitem"
                name: i18n.tr('Who can see the chat history?')
                value: ""
            }
            SettingsListItem {
                id: guest_access
                icon: "contact-group"
                name: i18n.tr('Guest access?')
                value: ""
            }

        }
    }
}
