import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Remove the device")

        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>Device ID</b>: %1".arg(currentDevice.device_id) )
        }
        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>Last IP</b>: %4".arg(currentDevice.last_seen_ip) )
        }
        Label {
            wrapMode: Text.Wrap
            color: UbuntuColors.red
            text: i18n.tr("Are you sure, that you want to remove this device?")
        }
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        TextField {
            id: passwordInput
            placeholderText: i18n.tr("Please enter your password")
            echoMode: TextInput.Password
            focus: true
        }
        Row {
            width: parent.width
            spacing: units.gu(1)
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Remove")
                color: UbuntuColors.red
                enabled: passwordInput.displayText !== ""
                onClicked: {
                    var device_id = currentDevice.device_id
                    var update = getDevices
                    var matrixObj = matrix
                    var password = passwordInput.text
                    matrix.post ( "/client/unstable/delete_devices", { "devices": [device_id] }, update, function (res) {
                        console.log( "erste Antwort", JSON.stringify(res) )
                        if ( "session" in res ) {
                            matrixObj.post ( "/client/unstable/delete_devices", {
                                "auth": {
                                    "type": "m.login.password",
                                    "session": res.session,
                                    "password": password,
                                    "user": matrixObj.matrixid
                                },
                                "devices": [device_id]
                            }, function (res) {
                                console.log( "fertig",JSON.stringify(res) )
                                update()
                            })
                        }
                        else update()
                    })
                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
