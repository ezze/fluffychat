// File: AddPhoneDialogActions.js
// Description: Actions for AddPhoneDialog.qml

function add(address, dialogue) {

    if (address.charAt(0) === "0") address = address.replace("0", matrix.countryTel)
    client_secret = "SECRET" + new Date().getTime()

    var callback = function (response) {
        if (response.error) return toast.show(response.error)
        if (response.sid) {
            phoneSettingsPage.sid = response.sid
        }
    }

    // Verify this address with this matrix id
    matrix.post("/client/r0/account/3pid/msisdn/requestToken", {
        client_secret: client_secret,
        country: matrix.countryCode,
        phone_number: address,
        send_attempt: 1,
        id_server: matrix.id_server
    }, callback, callback)
    PopupUtils.close(dialogue)
    PopupUtils.open(enterSMSToken)

}
