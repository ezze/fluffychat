import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    height: layout.height
    property var thisAddress: name

    ListItemLayout {
        id: layout
        title.text: name + (isCanonicalAlias ? " (<b>" + i18n.tr('Canonical alias') + "</b>)" : "")
        Icon {
            name: "bookmark"
            color: settings.mainColor
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
        }
    }

    trailingActions: ListItemActions {
        actions: [
        Action {
            iconName: "starred"
            visible: canEditCanonicalAlias && !isCanonicalAlias
            onTriggered: {
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.canonical_alias/", { "alias": thisAddress } )
            }
        }
        ]
    }

    leadingActions: ListItemActions {
        actions: [
        Action {
            iconName: "edit-delete"
            visible: canEditAddresses
            onTriggered: {
                matrix.remove("/client/r0/directory/room/%1".arg(encodeURIComponent(thisAddress)), {} )
            }
        }
        ]
    }
}
