// File: UserDevicesPageActions.js
// Description: Actions for UserDevicesPage.qml


function init () {
    model.clear()
    // Is the user tracking the device of this user?
    var isTrackingRequest = storage.query ( "SELECT tracking_devices " +
    " FROM Users WHERE matrix_id=?",
    [ matrix_id ])
    if ( isTrackingRequest.rows.length > 0 && isTrackingRequest.rows[0].tracking_devices ) {
        isTracking = true
    }

    if ( isTracking ) {
        // Load the devices from the database
        var res = storage.query ( "SELECT * " +
        " FROM Devices WHERE matrix_id=?",
        [ matrix_id ])
        for ( var i = 0; i < res.rows.length; i++ ) {
            model.append( { device: res.rows[i] } )
        }
        loading = false
    }
    else {
        // Request the devices from the server
        var device_keys = {}
        device_keys[matrix_id] = []
        var success_callback = function ( res ) {
            for ( var device_id in res.device_keys[matrix_id] ) {
                model.append( { device: { matrix_id: matrix_id, device_id: device_id, verified: false, keys_json: JSON.stringify(res.device_keys[matrix_id][device_id]) } } )
            }
            loading = false
        }
        matrix.post("/client/r0/keys/query", {device_keys: device_keys}, success_callback)
    }
}

function initChat () {
    model.clear()
    var res = storage.query ( "SELECT Devices.* " +
        " FROM Devices, Memberships WHERE Memberships.matrix_id=Devices.matrix_id AND Memberships.chat_id=? GROUP BY Devices.device_id ORDER BY Devices.matrix_id",
        [ activeChat ])
        for ( var i = 0; i < res.rows.length; i++ ) {
            model.append( { device: res.rows[i], user: res.rows[i].matrix_id } )
        }
        loading = false
}

function getDisplayPublicKey (activeDevice) {
    var publicKey = JSON.parse(activeDevice.keys_json).keys["ed25519:%1".arg(activeDevice.device_id)]
    for (var i =4; i < publicKey.length; i=i+5) publicKey = publicKey.substr(0,i) + " " + publicKey.substr(i, publicKey.length-1)
    return publicKey
}

function verify (activeDevice) {
    storage.query("UPDATE Devices SET verified=1 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function revoke (activeDevice) {
    storage.query("UPDATE Devices SET verified=0 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function block (activeDevice) {
    revoke()
    storage.query("UPDATE Devices SET blocked=1 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function unblock (activeDevice) {
    storage.query("UPDATE Devices SET blocked=0 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function getColor (activeDevice) {
    if(activeDevice.verified) return "green";
    if(activeDevice.blocked) return "red";
    return "black";
}

function switchDevice (activeDevice) {
    if(activeDevice.verified) {
        activeDevice.verified = false
        activeDevice.blocked = true
        storage.query("UPDATE Devices SET blocked=1, verified=0 WHERE device_id=?", [activeDevice.device_id])
    }
    else {
        activeDevice.verified = true
        activeDevice.blocked = false
        storage.query("UPDATE Devices SET blocked=0, verified=1 WHERE device_id=?", [activeDevice.device_id])
    }
    return activeDevice
}

function initEncryption () {
    var init = function () {
        matrix.put("/client/r0/rooms/%1/state/m.room.encryption".arg(activeChat), {"algorithm":"m.megolm.v1.aes-sha2"}, function () { initEncryption.visible=false }, null, 2)
    }
    showConfirmDialog (i18n.tr("This can not be undone!"), init)
}