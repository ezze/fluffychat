import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    height: layout.height
    property var thisAddress: name

    color: settings.darkmode ? "#202020" : "white"

    onClicked: shareController.shareLink ( "fluffychat://%1".arg(name) )

    ListItemLayout {
        id: layout
        title.text: name + (isCanonicalAlias ? " (<b>" + i18n.tr('Canonical alias') + "</b>)" : "")
        title.color: mainFontColor
        Icon {
            name: "bookmark"
            color: settings.mainColor
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
        }

        Icon {
            name: "share"
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
