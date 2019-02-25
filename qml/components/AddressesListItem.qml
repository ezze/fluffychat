import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    height: layout.height
    property var thisAddress: name

    color: mainLayout.darkmode ? "#202020" : "white"

    onClicked: {
        contentHub.toClipboard ( name )
        toast.show ( i18n.tr('Copied to clipboard') )
    }

    ListItemLayout {
        id: layout
        title.text: name + (isCanonicalAlias ? " (<b>" + i18n.tr('Canonical alias') + "</b>)" : "")
        title.color: mainFontColor
        Icon {
            name: "stock_link"
            color: mainLayout.mainColor
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
        }

        Icon {
            name: "edit-copy"
            width: units.gu(2)
            height: width
            SlotsLayout.position: SlotsLayout.Trailing
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
