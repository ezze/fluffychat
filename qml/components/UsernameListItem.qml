import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var matrix_id
    id: usernameListItem
    height: usernameListItemLayout.height
    color: Qt.rgba(0,0,0,0)
    ListItemLayout {
        id: usernameListItemLayout
        title.text: i18n.tr("Full username:")
        subtitle.text: matrix_id || ""

        Icon {
            name: "contact"
            SlotsLayout.position: SlotsLayout.Leading
            width: units.gu(3)
            height: width
        }

        Icon {
            name: "edit-copy"
            SlotsLayout.position: SlotsLayout.Trailing
            width: units.gu(3)
            height: width
        }
    }
    onClicked: contentHub.toClipboard ( matrix_id )
}
