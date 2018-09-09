import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Who is allowed to join?")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        SettingsListItem {
            name: i18n.tr("Public")
            icon: "private-browsing-exit"
            onClicked: {
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "public" } )
                PopupUtils.close(dialogue)
            }
        }
        SettingsListItem {
            name: i18n.tr("Knock")
            icon: "help"
            onClicked: {
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "knock" } )
                PopupUtils.close(dialogue)
            }
        }
        SettingsListItem {
            name: i18n.tr("Only invited users")
            icon: "private-tab-new"
            onClicked: {
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "invite" } )
                PopupUtils.close(dialogue)
            }
        }
        SettingsListItem {
            name: i18n.tr("Private")
            icon: "private-browsing"
            onClicked: {
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "private" } )
                PopupUtils.close(dialogue)
            }
        }
        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
