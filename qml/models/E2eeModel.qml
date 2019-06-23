import QtQuick 2.9
import E2ee 1.0

Item {

    id: e2eeModel

    function newE2eeAccount () {
        var newAccount = E2ee.createAccount ( matrix.matrixid )
        var keysJsonStr = E2ee.getIdentityKeys ()
        var keys = JSON.parse(keysJsonStr)
        E2ee.generateOneTimeKeys()
        var oneTimeKeys = JSON.parse(E2ee.getOneTimeKeys ())
        var signedOneTimeKeys = {}

        for ( var key in oneTimeKeys.curve25519 ) {
            signedOneTimeKeys["signed_curve25519:"+key] = { }
            signedOneTimeKeys["signed_curve25519:"+key]["keys"] = oneTimeKeys.curve25519[key]
            signedOneTimeKeys["signed_curve25519:"+key]["signatures"] = {}
            signedOneTimeKeys["signed_curve25519:"+key]["signatures"]["%1".arg(matrix.matrixid)] = {}
            signedOneTimeKeys["signed_curve25519:"+key]["signatures"]["%1".arg(matrix.matrixid)]["ed25519:%1".arg(matrix.deviceID)] = E2ee.signJsonString (oneTimeKeys.curve25519[key])
        }

        var requestData = {
            "device_keys": {
                "user_id": matrix.matrixid,
                "device_id": matrix.deviceID,
                "algorithms": supportedEncryptionAlgorithms,
                "keys": {}
            },
            "one_time_keys": signedOneTimeKeys
        }
        for ( var algorithm in keys ) {
            requestData["device_keys"]["keys"][algorithm+":"+matrix.deviceID] = keys[algorithm]
        }
        requestData["device_keys"] = signJson(requestData["device_keys"])

        var success_callback = function (result) {
            console.log("KEYS UPLOADED", JSON.stringify(result))
            if ( typeof result.one_time_key_counts.signed_curve25519 === "number" ) {
                matrix.one_time_key_counts = result.one_time_key_counts.signed_curve25519
                E2ee.markKeysAsPublished()
                matrix.e2eeAccountPickle = newAccount
            }
        }

        console.log("UPLOADING KEYS: ", JSON.stringify(requestData["device_keys"]))

        matrix.post ("/client/r0/keys/upload", requestData, success_callback, function (error) {
            console.log("ERROR UPLOADING KEYS:",JSON.stringify(error))
        })
    }


    function generateOneTimeKeys() {
        E2ee.generateOneTimeKeys()
        var oneTimeKeys = JSON.parse(E2ee.getOneTimeKeys ())
        var signedOneTimeKeys = {}

        for ( var key in oneTimeKeys.curve25519 ) {
            signedOneTimeKeys["signed_curve25519:"+key] = { }
            signedOneTimeKeys["signed_curve25519:"+key]["keys"] = oneTimeKeys.curve25519[key]
            signedOneTimeKeys["signed_curve25519:"+key]["signatures"] = {}
            signedOneTimeKeys["signed_curve25519:"+key]["signatures"]["%1".arg(matrix.matrixid)] = {}
            signedOneTimeKeys["signed_curve25519:"+key]["signatures"]["%1".arg(matrix.matrixid)]["ed25519:%1".arg(matrix.deviceID)] = E2ee.signJsonString (oneTimeKeys.curve25519[key])
        }
        var requestData = {
            "one_time_keys": signedOneTimeKeys
        }

        var success_callback = function (result) {
            console.log("KEYS UPLOADED", JSON.stringify(result))
            if ( typeof result.one_time_key_counts.signed_curve25519 === "number" ) {
                matrix.one_time_key_counts = result.one_time_key_counts.signed_curve25519
                E2ee.markKeysAsPublished()
            }
        }

        console.log("UPLOADING KEYS: ", JSON.stringify(requestData))

        matrix.post ("/client/r0/keys/upload", requestData, success_callback)
    }
    
    // Signs a json object with the device's fingerprint key.
    function signJson (jsonObj) {
        var unsigned = jsonObj.unsigned
        delete jsonObj.signatures
        delete jsonObj.unsigned
        var canonicalJson = JSON.stringify(jsonObj)
        jsonObj.signatures = {}
        jsonObj.signatures[matrix.matrixid] = {}
        jsonObj.signatures[matrix.matrixid]["ed25519:"+matrix.deviceID] = E2ee.signJsonString (canonicalJson)
        if (unsigned) jsonObj.unsigned = unsigned
    
        return jsonObj
    }


    // Checks the signature of a signed json object.
    function checkJsonSignature(key, signedJson, signature, device_id) {
        var signatures = signedJson.signatures
        var unsigned = signedJson.unsigned
        delete signedJson.signatures
        delete signedJson.unsigned
        var keyName = "ed25519:%1".arg(device_id)
        // TODO: Why is this not working?
        return E2ee.ed25519Verify(key, JSON.stringify(signedJson), signatures[signedJson.user_id][keyName])
    }


    // Decrypts an event depending on the algorithm and returns the decrypted content.
    function decrypt (event) {

        var decrypted = null

        if (event.content.algorithm === "m.olm.v1.curve25519-aes-sha2") {
            console.log("[DEBUG] Event is encrypted")

            var isPreKey = event.content.ciphertext[device_key].type === 0

            // Get device key
            var device_key
            for ( var key in event.content.ciphertext) {
                device_key = key
                break
            }
 
            var isCurrent = false
            console.log("[DEBUG] Check if the current session is the session")
            if ( isPreKey ) {
                isCurrent = matchesInboundSessionFrom(
                    event.content.sender_key, 
                    event.content.ciphertext[device_key].body
                )
            }
            else {
                isCurrent = matchesInboundSession(
                    event.content.ciphertext[device_key].body
                )
            }
            
            if (!isCurrent) {
                // Check if there is a olm session for this message
                console.log("[DEBUG] Check if there is a olm session in database")
                
                
                var res = storage.query ( "SELECT * FROM OlmSessions WHERE sender_key=? ORDER BY session_id", [ event.content.sender_key ] )

                if ( res.rows.length === 0 ) {
                    console.log("[DEBUG] No olm session found")

                    var newOlmSessionPickle
                    if ( isPreKey ) {
                        newOlmSessionPickle = E2ee.createInboundSessionFrom(
                            event.content.sender_key,
                            event.content.ciphertext[device_key].body,
                            matrix.matrixid
                        )
                    }
                    else {
                        newOlmSessionPickle = E2ee.createInboundSession(
                            event.content.ciphertext[device_key].body,
                            matrix.matrixid
                        )
                    }

                    storage.query ( "INSERT OR REPLACE INTO OlmSessions VALUES(?,?,?)",
                    [ device_key, event.content.sender_key, newOlmSessionPickle ])
                    decrypted = e2ee.decrypt ( event.content.ciphertext[device_key].body )
                    console.log("[DEBUG] Message decrypted", decrypted)
                }
                else {
                    console.log("[DEBUG] Existing olm session found")
                    var olmSessionRow = res.rows[0]
                    e2ee.setActiveSession ( olmSessionRow.pickle, matrix.matrixid )
                    console.log("[DEBUG] Olm session set")
                    decrypted = e2ee.decrypt ( event.content.ciphertext[device_key].body )
                    if ( decrypted === "" && isPreKey ) {
                        console.log("[DEBUG] Decrypting was not successful. Try to create a new session...")
                        newOlmSessionPickle = E2ee.createInboundSessionFrom(
                            event.content.sender_key,
                            event.content.ciphertext[device_key].body,
                            matrix.matrixid
                        )
                        storage.query ( "INSERT OR REPLACE INTO OlmSessions VALUES(?,?,?)",
                        [ device_key, event.content.sender_key, newOlmSessionPickle ])
                        decrypted = e2ee.decrypt ( event.content.ciphertext[device_key].body )
                    }
                    console.log("[DEBUG] Message decrypted", decrypted)
                }
            } 
        }
        else if (event.content.algorithm === "m.megolm.v1-aes-sha2") {
            var res = storage.query ( "SELECT * FROM InboundMegolmSessions WHERE room_id=? AND device_id=?", [ event.room_id, event.content.device_id ] )
            if ( res.rows.length > 0 ) {
                console.log("[DEBUG] Megolm session found")
                e2ee.restoreInboundGroupSession(res[0].pickle, matrix.matrixid)
                decrypted = e2ee.decryptGroupMessage( event.content.ciphertext )
                console.log("[DEBUG] Message decrypted", decrypted)
            }
            console.log("[DEBUG] No matching Inbound Group Session found...")
        }

        if (isCurrent) decrypted = e2ee.decrypt ( event.content.ciphertext[device_key].body )
        if (decrypted != null) {
            try {
                decrypted = JSON.parse(decrypted)
            }
            catch (e) {
                console.log("[ERROR] Message was decrypted but json parse was impossible")
                return null
            }
        }
        return decrypted
    }

    // Encrypts a message payload depending on the algorithm
    function sendOlmMessage ( content, device_id_list, identityKeys, callback  ) {
        console.log("[DEBUG] Try to send a olm message")
            
        var data = {
            "one_time_keys": device_id_list
        }
 
        var success_callback = function (resp) {
            console.log("[DEBUG] KeysClaim Response:", JSON.stringify(resp))
            var data = { "messages": {} }
            for ( var user_id in resp.one_time_keys ) {
                data.messages[user_id] = {}
                for ( var device_id in resp.one_time_keys[user_id] ) {
                    var keysObj = resp.one_time_keys[user_id][device_id]
                    var oneTimeKey
                    for ( var item in keysObj ) {
                        oneTimeKey = keysObj[item].key
                    }
                    console.log("[DEBUG] Create outbound session")
                    E2ee.createOutboundSession(identityKeys[device_id], oneTimeKey, matrix.matrixid)
                    var keys = JSON.parse(E2ee.getIdentityKeys())

                    data.messages[user_id][device_id] = {
                        "algorithm": "m.olm.v1.curve25519-aes-sha2",
                        "ciphertext": {},
                        "sender_key": "1234"//keys[curve25519]
                    }
                    data.messages[user_id][device_id].ciphertext[identityKeys[device_id]] = {
                        "body": E2ee.encrypt(JSON.stringify(content)),
                        "type": 0
                    }
                }
            }

            var txnid = new Date().getTime()
            console.log("[DEBUG] Send to devices:", JSON.stringify(data))
            matrix.put("/client/r0/sendToDevice/m.to_device/%1".arg(txnid), data, callback)
        }

        console.log("[DEBUG] KeysClaim Request:", JSON.stringify(data))
        matrix.post("/client/r0/keys/claim", data, success_callback)
    }
    
    // Encrypt megolm message
    function encryptMegolmMessage (content, room_id, callback) {
        console.log("[DEBUG] Try to send a megolm message to %1.".arg(room_id))
        var res = storage.query ( "SELECT encryption_outbound_pickle FROM Chats WHERE id=?", [ room_id ] )
        var megolmInPickle

        if (res.length === 0) return

        if (res.rows[0].encryption_outbound_pickle !== "") {
            console.log("[DEBUG] Found existing megolm session!")
            E2ee.restoreOutboundGroupSession(res.rows[0].encryption_outbound_pickle, matrix.matrixid)
            callback (E2ee.encryptGroupMessage(JSON.stringify(content)))
        }
        else {
            console.log("[DEBUG] No megolm session found! Try to create a new one...")
            var newPickle = E2ee.createOutboundGroupSession(matrix.matrixid)
            var inBoundKey = E2ee.getOutboundGroupSessionKey()
            megolmInPickle = E2ee.createInboundGroupSession(inBoundKey, matrix.matrixid)
            var olmContent = {
                "algorithm": "m.olm.v1.curve25519-aes-sha2",
                "room_id": room_id,
                "session_id": E2ee.getOutboundGroupSessionId(),
                "session_key": inBoundKey
            }
            console.log("[DEBUG] New megolm session created with ID: %1 and Key: %2".arg(olmContent.session_id).arg(olmContent.session_key))

            var device_id_row = storage.query( "SELECT Devices.device_id, Devices.keys_json, Memberships.matrix_id FROM Devices, Memberships WHERE Devices.matrix_id=Memberships.matrix_id AND Memberships.chat_id=? AND Devices.blocked=0  GROUP BY Devices.device_id", [ room_id ] )
            console.log("[DEBUG] Found %1 devices in this room".arg(device_id_row.rows.length))
            var devicesList = {}
            var identityKeys = {}
            for (var i = 0; i < device_id_row.rows.length; i++) {
                var row = device_id_row.rows[i]
                var keys = JSON.parse(row.keys_json)
                var keyName = "curve25519:%1".arg(row.device_id)
                if (!devicesList[row.matrix_id]) {
                    devicesList[row.matrix_id] = {}
                }
                identityKeys[row.device_id] = keys.keys[keyName]
                devicesList[row.matrix_id][row.device_id] = "signed_curve25519"
            }
                

            console.log("[DEBUG] devicesList ", JSON.stringify(devicesList))

            var success_callback = function () {
                console.log("[DEBUG] Store InboundMegolmSession")
                storage.query( "INSERT OR REPLACE INTO InboundMegolmSessions VALUES(?,?,?)", [
                    room_id,
                    matrix.device_id,
                    megolmInPickle
                ] )
                storage.query( "UPDATE Chats SET encryption_outbound_pickle=? WHERE id=?", [
                    megolmInPickle,
                    room_id
                ] )
                callback (E2ee.encryptGroupMessage(JSON.stringify(content)))
            }
            sendOlmMessage(olmContent, devicesList, identityKeys, success_callback)
        }
    }

}
