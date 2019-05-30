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

function getDisplayPublicKey () {
    var publicKey = JSON.parse(activeDevice.keys_json).keys["ed25519:%1".arg(activeDevice.device_id)]
    for (var i =4; i < publicKey.length; i=i+5) publicKey = publicKey.substr(0,i) + " " + publicKey.substr(i, publicKey.length-1)
    return publicKey
}

function verify () {
    console.log("Verify now!")
    storage.query("UPDATE Devices SET verified=1 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function revoke () {
    storage.query("UPDATE Devices SET verified=0 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function block () {
    revoke()
    storage.query("UPDATE Devices SET blocked=1 WHERE device_id=?", [activeDevice.device_id])
    reload()
}

function unblock () {
    storage.query("UPDATE Devices SET blocked=0 WHERE device_id=?", [activeDevice.device_id])
    reload()
}
