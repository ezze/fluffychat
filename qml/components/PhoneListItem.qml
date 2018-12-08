import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    id: listItem
    height: layout.height
    property var thisAddress: name

    color: settings.darkmode ? "#202020" : "white"

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainFontColor

        Icon {
            name: "phone-symbolic"
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
                    matrix.post ( "/client/unstable/account/3pid/delete", { medium: "msisdn", address: thisAddress }, phoneSettingsPage.sync )
                } )
            }
        }
        ]
    }
}
