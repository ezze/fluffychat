import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/DevicesSettingsPageActions.js" as PageActions

Page {
    id: devicesSettingsPage
    anchors.fill: parent

    property var currentDevice

    header: PageHeader {
        title: i18n.tr('Devices')
    }

    ScrollView {

        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: devicesSettingsPage.width
            id: deviceList

            Component.onCompleted: PageActions.getDevices ()
        }
    }

    signal getDevices ()
    onGetDevices: PageActions.getDevices ()

    RemoveDeviceDialog { id: removeDeviceDialog }
}
