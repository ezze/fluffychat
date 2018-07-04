import QtQuick 2.4
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
            color: settings.mainColor
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
                enabled: oldPass.displayText !== "" && newPass.displayText !== "" && newPass2.displayText !== ""
                onClicked: {
                    if ( newPass.displayText !== newPass2.displayText ) {
                        dialogue.title = i18n.tr("The passwords do not match")
                    }
                    else {
                        dialogue.title = i18n.tr("Change your password")
                        matrix.post ( "/client/r0/account/password",{
                            "auth": {
                                "password": oldPass.displayText,
                                "type": "m.login.password",
                                "user": matrix.matrixid
                            },
                            "new_password": newPass.displayText
                        } )
                        PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }
}
