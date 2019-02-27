// File: RemoveDeviceDialogActions.js
// Description: Actions for RemoveDeviceDialog.qml

function removeDevice ( device_id, password, dialogue ) {
    var authData = {
        "auth": {
            "type": "m.login.password",
            "session": res.session,
            "user": matrix.matrixid,
            "password": passwordInput.text
        },
        "devices": [device_id]
    }

    var firstResponse = function (res) {
        if ( "session" in res ) {
            matrix.post ( "/client/unstable/delete_devices", authData, getDevices, null, 2)
        }
        else getDevices()
    }

    matrix.post ( "/client/unstable/delete_devices", { "devices": [device_id] }, getDevices, firstResponse, null, 2)
    PopupUtils.close(dialogue)
}
