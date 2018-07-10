import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Disable your account")
        Rectangle {
            height: icon.height
            Icon {
                id: icon
                width: parent.width / 2
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                name: "security-alert"
                color: UbuntuColors.red
            }
        }
        Label {
            text: i18n.tr("Are you sure, that you want to disable your account? This can not be undone!")
            color: UbuntuColors.red
            width: parent.width
            wrapMode: Text.Wrap
        }

        TextField {
            id: oldPass
            placeholderText: i18n.tr("Enter your old password")
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
                text: i18n.tr("Disable")
                color: UbuntuColors.red
                enabled: oldPass.displayText !== ""
                onClicked: {
                    var setPusherCallback = function () {
                        matrix.post ( "/client/r0/account/deactivate", {
                            "auth": {
                                "password": oldPass.displayText,
                                "type": "m.login.password",
                                "user": matrix.matrixid
                            }
                        } )
                    }
                    pushclient.setPusher ( false, setPusherCallback, setPusherCallback )
                }
            }
        }
    }
}
