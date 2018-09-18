import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Please enter the validation code")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        TextField {
            id: addressTextField
            placeholderText: i18n.tr("Validation code")
            focus: true
            inputMethodHints: Qt.ImhDigitsOnly
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
                text: i18n.tr("Connect")
                color: UbuntuColors.green
                enabled: addressTextField.displayText !== ""
                onClicked: {
                    var success_callback = function () {
                        PopupUtils.close(dialogue)
                        phoneSettingsPage.sync ()
                    }
                    matrix.post ( "/identity/api/v1/validate/msisdn/submitToken", {
                        client_secret: client_secret,
                        sid: sid,
                        token: addressTextField.displayText
                    }, success_callback )
                }
            }
        }
    }
}
