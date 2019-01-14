import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    id: deviceListItem

    color: settings.darkmode ? "#202020" : "white"

    height: layout.height

    property var device

    onClicked: {
        currentDevice = device
        PopupUtils.open(removeDeviceDialog)
    }

    ListItemLayout {
        id: layout
        width: parent.width
        title.font.bold: settings.deviceID == device.device_id
        title.text: (settings.deviceID === device.device_id ? i18n.tr( "This device" ) + " " : "") + device.display_name || device.device_id
        subtitle.text: i18n.tr("Last seen: ") + stamp.getChatTime ( device.last_seen_ts )
        Icon {
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
            name: "phone-smartphone-symbolic"
        }
        Icon {
            width: units.gu(2)
            height: units.gu(2)
            SlotsLayout.position: SlotsLayout.Trailing
            name: "edit-delete"
            color: UbuntuColors.red
        }
    }


}
