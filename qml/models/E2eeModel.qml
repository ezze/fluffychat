import QtQuick 2.9
import E2ee 1.0

Item {

    id: e2eeModel

    // Initialize the e2e encryption account
    function init () {
        if ( matrix.e2eeAccountPickle === "" ) {
            console.error ( "🔐[E2EE] Create new OLM account" )
            e2eeModel.newE2eeAccount ()
        }
        else {
            console.log("🔐[E2EE] Restore account")
            if ( E2ee.restoreAccount ( matrix.e2eeAccountPickle, matrix.matrixid ) === false ) {
                console.error ( "❌[Error] Could not restore E2ee account" )
                e2eeModel.newE2eeAccount ()
            }
        }
    }

    function newE2eeAccount () {
        console.log("New E2ee Account")
        var newAccount = E2ee.createAccount ( matrix.matrixid )
        var keysJsonStr = E2ee.getIdentityKeys ()
        var keys = JSON.parse(keysJsonStr)
        E2ee.generateOneTimeKeys()
        var oneTimeKeys = JSON.parse(E2ee.getOneTimeKeys ())
        var signedOneTimeKeys = {}

        for ( var key in oneTimeKeys.curve25519 ) {
            signedOneTimeKeys["signed_curve25519:"+key] = { }
            signedOneTimeKeys["signed_curve25519:"+key]["key"] = oneTimeKeys.curve25519[key]
            signedOneTimeKeys["signed_curve25519:"+key] = signJson(signedOneTimeKeys["signed_curve25519:"+key])
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
            signedOneTimeKeys["signed_curve25519:"+key] = signJson(signedOneTimeKeys["signed_curve25519:"+key])
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

    // FIXME: Ugly way to get a sorted JSON string
    // https://stackoverflow.com/questions/16167581/sort-object-properties-and-json-stringify/53593328#53593328
    function orderedStringify(obj) {
        var allKeys = [];
        JSON.stringify(obj, function (k, v) { allKeys.push(k); return v; });
        return JSON.stringify(obj, allKeys.sort()); 
    }
    
    // Signs a json object with the device's fingerprint key.
    function signJson (jsonObj) {
        var unsigned = jsonObj.unsigned
        var signatures = jsonObj.signatures
        delete jsonObj.signatures
        delete jsonObj.unsigned
        var canonicalJson = orderedStringify(jsonObj)
        if (signatures) jsonObj.signatures = signatures
        else jsonObj.signatures = {}
        jsonObj.signatures[matrix.matrixid] = {}
        jsonObj.signatures[matrix.matrixid]["ed25519:"+matrix.deviceID] = E2ee.signJsonString (canonicalJson)
        if (unsigned) jsonObj.unsigned = unsigned

        return jsonObj
    }

    // Checks the signature of a signed json object.
    function checkJsonSignature(key, signedJson, user_id, device_id) {
        var signatures = signedJson.signatures
        if (signatures[user_id] === undefined) return false
        var unsigned = signedJson.unsigned
        delete signedJson.signatures
        delete signedJson.unsigned
        var keyName = "ed25519:%1".arg(device_id)
        if (signatures[user_id][keyName] === undefined) return false
        // TODO: Why is this not working?
        return E2ee.ed25519Verify(key, orderedStringify(signedJson), signatures[user_id][keyName])
    }


    // Decrypts an event depending on the algorithm and returns the decrypted content.
    function decrypt (event) {

        var decrypted = null

        if (event.content.algorithm === "m.olm.v1.curve25519-aes-sha2") {
            console.log("[DEBUG] Event is encrypted with olm", JSON.stringify(event))

            var keysJsonStr = E2ee.getIdentityKeys ()
            if (keysJsonStr === "") return null
            var keys = JSON.parse(keysJsonStr)

            // Get device key
            var device_key
            for ( var key in event.content.ciphertext) {
                if (key === keys["curve25519"]) {
                    device_key = key
                    break
                }
            }
            if (device_key === null) {
                console.log("[ERROR] Own curve25519 key not found")
                return null
            }

            var isPreKey = event.content.ciphertext[device_key].type === 0
            if (isPreKey) console.log("[DEBUG] Its a prekey message because type ===",event.content.ciphertext[device_key].type)
 
            var isCurrent = false
            if ( false && isPreKey ) {  // Currently bugged!
                console.log("[DEBUG] Check if the current session is the session")
                isCurrent = E2ee.matchesInboundSession(
                    event.content.ciphertext[device_key].body
                )
            }
            
            if (!isCurrent) {
                // Check if there is a olm session for this message
                console.log("[DEBUG] Check if there is a olm session in database")
                
                
                var res = storage.query ( "SELECT * FROM OlmSessions WHERE sender_key=?", [ event.content.sender_key ] )

                if ( res.rows.length === 0 ) {
                    console.log("[DEBUG] No olm session found in database")

                    var newOlmSessionPickle
                    if ( isPreKey ) {
                        print("[DEBUG] Create Inbound Session From!", event.content.sender_key, device_key)
                        E2ee.removeSession();
                        newOlmSessionPickle = E2ee.createInboundSession(
                            event.content.ciphertext[device_key].body,
                            matrix.matrixid
                        )
                    }
                    else return null
                    print("newOlmSessionPickle",JSON.stringify(newOlmSessionPickle))
                    if (newOlmSessionPickle.session === undefined) return null

                    storage.query ( "INSERT OR REPLACE INTO OlmSessions VALUES(?,?,?)",
                    [ device_key, event.content.sender_key, newOlmSessionPickle.session ])
                    decrypted = E2ee.decrypt ( event.content.ciphertext[device_key].body )
                    console.log("[DEBUG] OLM Message decrypted", JSON.stringify(decrypted))
                }
                else {
                    var olmSessionRow = res.rows[0]
                    console.log("[DEBUG] Existing olm session found", olmSessionRow.pickle)
                    E2ee.setActiveSession ( olmSessionRow.pickle, matrix.matrixid )
                    console.log("[DEBUG] Olm session set")
                    decrypted = E2ee.decrypt ( event.content.ciphertext[device_key].body )
                    if ( decrypted === "" && isPreKey ) {
                        console.log("[DEBUG] Decrypting was not successful. Try to create a new session...")
                        newOlmSessionPickle = E2ee.createInboundSessionFrom(
                            event.content.sender_key,
                            event.content.ciphertext[device_key].body,
                            matrix.matrixid
                        )
                        storage.query ( "INSERT OR REPLACE INTO OlmSessions VALUES(?,?,?)",
                        [ device_key, event.content.sender_key, newOlmSessionPickle.session ])
                        decrypted = E2ee.decrypt ( event.content.ciphertext[device_key].body )
                    }
                    console.log("[DEBUG] OLM Message decrypted", JSON.stringify(decrypted))
                }
            } 
            if (isCurrent && decrypted == null) decrypted = E2ee.decrypt ( event.content.ciphertext[device_key].body )
        }
        else if (event.content.algorithm === "m.megolm.v1.aes-sha2") {
            console.log("Try to decrypt group message with session:", event.content.session_id)
            var res = storage.query ( "SELECT * FROM InboundMegolmSessions WHERE session_id=?", [ event.content.session_id ] )
            if ( res.rows.length > 0 ) {
                console.log("[DEBUG] Megolm session found")
                E2ee.restoreInboundGroupSession(res.rows[0].pickle, matrix.matrixid)
                decrypted = E2ee.decryptGroupMessage( event.content.ciphertext )
                for (var key in decrypted) event[key] = decrypted[key]
                decrypted = event
                console.log("[DEBUG] Message decrypted")
            }
            else console.log("[DEBUG] No matching Inbound Group Session found...")
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
            var ciphertext = {}
            for ( var user_id in resp.one_time_keys ) {
                data.messages[user_id] = {}
                for ( var device_id in resp.one_time_keys[user_id] ) {
                    var keysObj = resp.one_time_keys[user_id][device_id]
                    var oneTimeKey
                    for ( var item in keysObj ) {
                        oneTimeKey = keysObj[item].key
                    }
                    console.log("[DEBUG] Create outbound session with device " + device_id + " oneTimeKey " + oneTimeKey + " and identity key " + identityKeys[device_id])
                    E2ee.removeSession();
                    E2ee.createOutboundSession(identityKeys[device_id], oneTimeKey, matrix.matrixid)
                    var encrypted = E2ee.encrypt(JSON.stringify(content))

                    var keys = JSON.parse(E2ee.getIdentityKeys())

                    data.messages[user_id][device_id] = {
                        "algorithm": "m.olm.v1.curve25519-aes-sha2",
                        "ciphertext": {},
                        "sender_key": keys["curve25519"]
                    }
                    data.messages[user_id][device_id].ciphertext[identityKeys[device_id]] = {
                        "body": encrypted,
                        "type": 0
                    }
                }
            }

            var txnid = new Date().getTime()
            console.log("[DEBUG] Send to devices:", JSON.stringify(data))
            matrix.put("/client/r0/sendToDevice/m.room.encrypted/%1".arg(txnid), data, callback)
        }

        console.log("[DEBUG] KeysClaim Request:", JSON.stringify(data))
        matrix.post("/client/r0/keys/claim", data, success_callback)
    }
    
    // Encrypt megolm message
    function encryptMegolmMessage (content, room_id, callback) {
        content = {
            "room_id": room_id,
            "content": content,
            "type": "m.room.message"
        }
        var res = storage.query ( "SELECT encryption_outbound_pickle FROM Chats WHERE id=?", [ room_id ] )
        var megolmInPickle

        if (res.length === 0) return

        if (res.rows[0].encryption_outbound_pickle !== "") {
            E2ee.restoreOutboundGroupSession(res.rows[0].encryption_outbound_pickle, matrix.matrixid)
            callback (E2ee.encryptGroupMessage(JSON.stringify(content)))
        }
        else {
            var newPickle = E2ee.createOutboundGroupSession(matrix.matrixid)
            var inBoundKey = E2ee.getOutboundGroupSessionKey()
            var sessionId = E2ee.getOutboundGroupSessionId()
            megolmInPickle = E2ee.createInboundGroupSession(inBoundKey, matrix.matrixid)
            var olmContent = {
                "content": {
                    "algorithm": "m.megolm.v1.aes-sha2",
                    "room_id": room_id,
                    "session_id": E2ee.getOutboundGroupSessionId(),
                    "session_key": inBoundKey
                },
                "type": "m.room_key"
            }

            var device_id_row = storage.query( "SELECT Devices.device_id, Devices.keys_json, Memberships.matrix_id FROM Devices, Memberships WHERE Devices.matrix_id=Memberships.matrix_id AND Memberships.chat_id=? AND Devices.blocked=0  GROUP BY Devices.device_id", [ room_id ] )
            console.log("[DEBUG] Found %1 devices in this room".arg(device_id_row.rows.length))
            var devicesList = {}
            var identityKeys = {}
            for (var i = 0; i < device_id_row.rows.length; i++) {
                var row = device_id_row.rows[i]
                if (row.device_id === matrix.deviceID) continue
                var keys = JSON.parse(row.keys_json)
                var keyName = "curve25519:%1".arg(row.device_id)
                if (!devicesList[row.matrix_id]) {
                    devicesList[row.matrix_id] = {}
                }
                identityKeys[row.device_id] = keys.keys[keyName]
                devicesList[row.matrix_id][row.device_id] = "signed_curve25519"
            }

            console.log("[DEBUG] devicesList identityKeys ", JSON.stringify(identityKeys))

            var success_callback = function () {
                console.log("[DEBUG] Store InboundMegolmSession with session_id:", sessionId)
                storage.query( "INSERT OR REPLACE INTO InboundMegolmSessions VALUES(?,?,?)", [
                    room_id,
                    sessionId,
                    megolmInPickle
                ] )
                storage.query( "UPDATE Chats SET encryption_outbound_pickle=? WHERE id=?", [
                    newPickle,
                    room_id
                ] )
                callback (E2ee.encryptGroupMessage(JSON.stringify(content)))
            }
            sendOlmMessage(olmContent, devicesList, identityKeys, success_callback)
        }
    }

}
