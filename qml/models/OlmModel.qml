import QtQuick 2.0
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import Qolm 1.0

Item {
    id: olmModel
    property var account: null;

    Settings {
        property alias account: olmModel.account
    }

    Component.onCompleted: {
        console.log("OlmModel created")
        console.log("Calling speak function...")
        Qolm.speak()
    }
}
