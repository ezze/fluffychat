import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    id: listItem
    height: layout.height
    property var thisAddress: name

    ListItemLayout {
        id: layout
        title.text: name
        Icon {
            name: "email"
            color: settings.mainColor
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
        }
    }

    leadingActions: ListItemActions {
        actions: [
        Action {
            iconName: "edit-delete"
            onTriggered: {
                showConfirmDialog ( i18n.tr('Remove this email address?'), function () {
                    matrix.post ( "/client/unstable/account/3pid/delete", { medium: "email", address: thisAddress }, emailSettingsPage.sync )
                } )
            }
        }
        ]
    }
}
