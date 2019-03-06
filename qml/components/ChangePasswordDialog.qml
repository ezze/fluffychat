import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Change your password")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }
        TextField {
            id: oldPass
            placeholderText: i18n.tr("Enter your old password")
            echoMode: TextInput.Password
            focus: true
        }
        TextField {
            id: newPass
            placeholderText: i18n.tr("Enter your new password")
            echoMode: TextInput.Password
        }
        TextField {
            id: newPass2
            placeholderText: i18n.tr("Please repeat")
            echoMode: TextInput.Password
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
                text: i18n.tr("Change")
                color: UbuntuColors.green
                enabled: oldPass.displayText !== "" && newPass.displayText !== "" && newPass2.displayText !== "" && newPass.text === newPass2.text
                onClicked: {
                    var _toast = toast
                    var toastText = i18n.tr("Password has been changed")
                    var successCallback = function () {
                        _toast.show ( toastText )
                    }
                    matrix.post ( "/client/r0/account/password",{
                        "auth": {
                            "password": oldPass.text,
                            "type": "m.login.password",
                            "user": matrix.matrixid
                        },
                        "new_password": newPass.text
                    }, successCallback, null, 2 )
                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
