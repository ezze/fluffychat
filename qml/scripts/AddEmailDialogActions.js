// File: AddEmailDialogActions.js
// Description: Actions for AddEmailDialog.qml

function add ( address, dialogue ) {
    var secret = "SECRET:" + new Date().getTime()

    var success_callback = function ( response ) {
        var sendsecondReqSid = function () { sendSecondReq ( response.sid ) }
        showConfirmDialog ( i18n.tr("Have you confirmed your email address?"), sendsecondReqSid )
    }

    var sendSecondReq = function ( sid ) {
        var threePidCreds = {
            client_secret: secret,
            sid: sid,
            id_server: matrix.id_server
        }
        matrix.post ("/client/r0/account/3pid", {
            bind: true,
            threePidCreds: threePidCreds
        }, emailSettingsPage.sync, null, 2 )
    }

    // Verify this address with this matrix id
    matrix.post ( "/client/r0/account/3pid/email/requestToken", {
        client_secret: secret,
        email: address,
        send_attempt: 1,
        id_server: matrix.id_server
    }, success_callback, null, 2)

    PopupUtils.close(dialogue)
}
