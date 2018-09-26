import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Connect new phone number") + i18n.tr("...")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        Row {
            Button {
                width: units.gu(8)
                text: settings.countryCode + " +%1".arg(settings.countryTel)
                onClicked: dialogue.title = i18n.tr("Please log out to change your country")
            }
            TextField {
                id: addressTextField
                placeholderText: i18n.tr("Phone number...")
                Keys.onReturnPressed: loginTextField.focus = true
                inputMethodHints: Qt.ImhDigitsOnly
                width: parent.width - units.gu(8)
                focus: true
            }
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
                    var address = addressTextField.displayText
                    if ( address.charAt(0) === "0" ) address = address.replace( "0", settings.countryTel )
                    PopupUtils.close(dialogue)
                    var secret = "SECRET:" + new Date().getTime()
                    var confirmText = i18n.tr("Have you confirmed your phone number?")
                    var id_server = settings.id_server
                    var _matrix = matrix
                    var _showConfirmDialog = showConfirmDialog
                    var _phoneSettingsPage = phoneSettingsPage
                    var success_callback = function ( response ) {
                        sid = response.sid
                        client_secret = secret
                        PopupUtils.close(dialogue)
                        PopupUtils.open(enterSMSToken)
                    }
                    // Verify this address with this matrix id
                    matrix.post ( "/client/r0/account/3pid/msisdn/requestToken", {
                        client_secret: secret,
                        country: settings.countryCode,
                        phone_number: address,
                        send_attempt: 1,
                        id_server: settings.id_server
                    }, success_callback)
                }
            }
        }
    }
}
