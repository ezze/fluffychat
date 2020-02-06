import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/UserDevicesPageActions.js" as PageActions

ListItem {
    id: deviceListItem

    color: mainLayout.darkmode ? "#202020" : "white"

    height: layout.height

    property var deviceItem: device

    property var keys: JSON.parse(deviceItem.keys_json)

    ListItemLayout {
        id: layout
        width: parent.width
        title.text: keys.unsigned && keys.unsigned.device_display_name || deviceItem.device_id
        title.color: PageActions.getColor(deviceItem)
        title.font.bold: deviceItem.device_id === matrix.deviceID
        summary.text: PageActions.getDisplayPublicKey(deviceItem)
        Switch {
            id: checkBox
            SlotsLayout.position: SlotsLayout.Trailing
            enabled: false
            Component.onCompleted: {
                checked = deviceItem.verified && !deviceItem.blocked
                enabled = true
            }
            onCheckedChanged: if ( enabled ) deviceItem = PageActions.switchDevice(deviceItem)
        }
    }

}
