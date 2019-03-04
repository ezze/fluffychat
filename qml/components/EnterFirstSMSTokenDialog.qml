import QtQuick 2.9
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
            color: mainLayout.mainColor
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
                onClicked: {
                    PopupUtils.close(dialogue)
                    layout.init ()
                }
            }
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Connect")
                color: UbuntuColors.green
                enabled: addressTextField.displayText !== "" && root.firstSMSSid !== null
                onClicked: {
                    var firstSuccessCallback = function () {

                        var threePidCreds = {
                            client_secret: root.firstSMSClientSecret,
                            sid: firstSMSSid,
                            id_server: matrix.id_server
                        }
                        matrix.post ("/client/r0/account/3pid", {
                            bind: true,
                            threePidCreds: threePidCreds
                        }, null, null, 2 )
                        PopupUtils.close(dialogue)
                    }

                    var firstErrorCallback = function ( error ) {
                        dialogue.title = error.error
                    }
                    var data = {
                        client_secret: root.firstSMSClientSecret,
                        sid: firstSMSSid,
                        token: addressTextField.displayText
                    }
                    console.log(JSON.stringify (data))
                    matrix.post ( "/identity/api/v1/validate/msisdn/submitToken", data, firstSuccessCallback, firstErrorCallback, 2 )
                }
            }
        }
    }
}
