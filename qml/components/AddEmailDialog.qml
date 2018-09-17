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
                    // TODO: Connect this email address
                    var address = addressTextField.displayText
                    matrix.get("/identity/api/v1/lookup", { "medium": "email", "address": address }, function ( res ) {
                        console.log(JSON.stringify(res))
                        if ( res.mxid ) {
                            // Is this address already associated with this matrix id?
                            if ( res.mxid === matrix.matrixid ) {
                                storage.query ( "INSERT OR REPLACE INTO ThirdPIDs VALUES(?,?)", [ "email", address ], emailSettingsPage.update)
                                PopupUtils.close(dialogue)
                            }
                            else {
                                // Is this address already associated with another matrix id?
                                dialogue.title = i18n.tr("This address is already connected with another account!")
                            }
                        }
                        else {
                            PopupUtils.close(dialogue)
                            // Verify this address with this matrix id
                            matrix.post ( "/client/r0/account/email/requestToken", {
                                client_secret: "SECRET:" + new Date().getTime(),
                                email: address,
                                send_attempt: 1,
                                id_server: settings.id_server
                            }, function () {
                                storage.query ( "INSERT OR REPLACE INTO ThirdPIDs VALUES(?,?)", [ "email", address ], emailSettingsPage.update)
                                toast.show ( i18n.tr("A confirmation email has been sent to %1").arg(address) )
                            })

                        }
                    })
                }
            }
        }
    }
}
