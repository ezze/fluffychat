// File: DevicesSettingsPageActions.js
// Description: Actions for DevicesSettingsPage.qml


function getDevices () {
    matrix.get ( "/client/r0/devices", null, function ( response ) {
        deviceList.children = ""
        for ( var i = 0; i < response.devices.length; i++ ) {
            var newDeviceListItem = Qt.createComponent("../components/DeviceListItem.qml")
            newDeviceListItem.createObject(deviceList, { device: response.devices[i] } )
        }
    }, null, 2)
}
