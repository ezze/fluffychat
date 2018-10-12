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
        Column {
            SettingsListItem {
                name: i18n.tr("Public")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "public" } )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Knock")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "knock" } )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Only invited users")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "invite" } )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Private")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.join_rules/", { "join_rule": "private" } )
                    PopupUtils.close(dialogue)
                }
            }
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
