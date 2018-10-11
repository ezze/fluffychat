import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr('Who can see the chat history?')
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: defaultMainColor
        }
        Column {
            SettingsListItem {
                name: i18n.tr("Everyone")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "shared" } )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Joined and invited chat participants")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "invited" } )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Only chat participants")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.history_visibility/", { "history_visibility": "joined" } )
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
