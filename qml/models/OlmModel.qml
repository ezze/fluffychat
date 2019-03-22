import QtQuick 2.0
import Ubuntu.Components 1.3
import Qolm 1.0

Item {
    id: olmModel

    Component.onCompleted: {
        var keys = JSON.parse(Qolm.createAccount().split("}")[0] + "}")
        console.log("Keys received\nFingerprint key: '%1'\nIdentity key: '%2'".arg(keys["ed25519"]).arg(keys["curve25519"]))
    }
}
