import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Connect new email address")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        TextField {
            id: addressTextField
            placeholderText: i18n.tr("youremail@domain.com")
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
                text: i18n.tr("Connect")
                color: UbuntuColors.green
                enabled: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test( addressTextField.displayText )
                onClicked: {
                    var address = addressTextField.displayText
                    PopupUtils.close(dialogue)
                    var secret = "SECRET:" + new Date().getTime()
                    var confirmText = i18n.tr("Have you confirmed your email address?")
                    var id_server = settings.id_server
                    var _matrix = matrix
                    var _showConfirmDialog = showConfirmDialog
                    var _emailSettingsPage = emailSettingsPage
                    var success_callback = function ( response ) {
                        var sid = response.sid
                        _showConfirmDialog ( confirmText, function () {
                            var threePidCreds = {
                                client_secret: secret,
                                sid: sid,
                                id_server: id_server
                            }
                            _matrix.post ("/client/r0/account/3pid", {
                                bind: true,
                                threePidCreds: threePidCreds
                            }, _emailSettingsPage.sync )
                        } )
                    }
                    // Verify this address with this matrix id
                    matrix.post ( "/client/r0/account/3pid/email/requestToken", {
                        client_secret: secret,
                        email: address,
                        send_attempt: 1,
                        id_server: settings.id_server
                    }, success_callback)
                }
            }
        }
    }
}
