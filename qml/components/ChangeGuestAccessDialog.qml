import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr('Guest access?')
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: defaultMainColor
        }
        Column {
            SettingsListItem {
                name: i18n.tr("Can join")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.guest_access/", { "guest_access": "can_join" } )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Forbidden")
                icon: "view-collapse"
                onClicked: {
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.guest_access/", { "guest_access": "forbidden" } )
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
