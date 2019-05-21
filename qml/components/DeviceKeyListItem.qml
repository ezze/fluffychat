import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

ListItem {
    id: deviceListItem

    color: mainLayout.darkmode ? "#202020" : "white"

    height: layout.height

    ListItemLayout {
        id: layout
        width: parent.width
        title.text: device.device_id
        title.font.bold: device.device_id === matrix.deviceID
        Icon {
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
            name: "phone-smartphone-symbolic"
            color: device.verified ? "green" : "red"
        }
    }

}
