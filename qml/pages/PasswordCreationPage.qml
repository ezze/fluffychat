import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var loginDomain: ""

    var sid: null
    var client_secret: null


    Component.onCompleted: {
        // If there is a desired phone number, try to register it now:
        if ( desiredPhoneNumber !== null ) {
            toast.show( i18n.tr("Registering phone number...") )
            var secret = "SECRET:" + new Date().getTime()
            var success_callback = function ( response ) {
                sid = response.sid
                client_secret = secret
                PopupUtils.open(enterSMSToken)
            }
            // Verify this address with this matrix id
            matrix.post ( "/client/r0/account/3pid/msisdn/requestToken", {
                client_secret: secret,
                country: settings.countryCode,
                phone_number: desiredPhoneNumber,
                send_attempt: 1,
                id_server: settings.id_server
            }, success_callback)
        }
    }


    EnterSMSToken: { id: enterSMSTOken }


    header: FcPageHeader {
        title: i18n.tr('Your password')

        leadingActionBar {
            actions: [
            Action {
                iconName: "settings"
                onTriggered: PopupUtils.open(dialog)
            }
            ]
        }
        trailingActionBar {
            actions: [
            Action {
                iconName: "ok"
                onTriggered: {
                    mainStack.toStart()
                }
            }
            ]
        }
    }

    Component {
        id: dialog

        Dialog {
            id: dialogue
            title: i18n.tr("Choose your own password")
            Rectangle {
                height: units.gu(0.2)
                width: parent.width
                color: settings.mainColor
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
                    enabled: newPass.displayText !== "" && newPass2.displayText !== ""
                    onClicked: {
                        if ( newPass.displayText !== newPass2.displayText ) {
                            dialogue.title = i18n.tr("The passwords do not match")
                        }
                        else {
                            dialogue.title = i18n.tr("Change your password")
                            matrix.post ( "/client/r0/account/password",{
                                "auth": {
                                    "password": generated_password,
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

    ScrollView {
        id: scrollView
        width: root.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: root.width
            spacing: units.gu(2)

            Icon {
                id: banner
                name: "lock"
                color: settings.mainColor
                width: root.width
                height: width * 2/5
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("In order to restore your account, please make a note of this secret")
            }

            TextField {
                anchors.horizontalCenter: parent.horizontalCenter
                id: loginTextField
                text: generated_password
                width: elemWidth
                readOnly: true
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Copy to clipboard")
                onClicked: {
                    mimeData.text = generated_password
                    Clipboard.push( mimeData )
                }
            }

        }
    }

    MimeData {
        id: mimeData
        text: ""
    }

}
