import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    id: devicesSettingsPage
    anchors.fill: parent

    property var currentDevice

    function getDevices () {
        matrix.get ( "/client/r0/devices", null, function ( response ) {
            deviceList.children = ""
            for ( var i = 0; i < response.devices.length; i++ ) {
                var newDeviceListItem = Qt.createComponent("../components/DeviceListItem.qml")
                newDeviceListItem.createObject(deviceList, { device: response.devices[i] } )
            }
        }, null, 2)
    }


    header: FcPageHeader {
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

            Component.onCompleted: getDevices ()
        }
    }

    RemoveDeviceDialog { id: removeDeviceDialog }
}
