// File: PasswordCreationPageActions.js
// Description: Actions for PasswordCreationPage.qml

function register () {
    matrix.register ( desiredUsername.toLowerCase(), loginTextField.text, (loginDomain || defaultDomain), "UbuntuPhone", function () {

        if ( desiredPhoneNumber !== null ) {
            client_secret = "SECRET:" + new Date().getTime()
            var _page = passwordCreationPage
            PopupUtils.open(enterSMSToken)
            var success_callback = function ( response ) {
                if ( response.error ) return toast.show ( response.error )
                if ( response.sid ) {
                    _page.sid = response.sid
                }
            }
            // Verify this address with this matrix id
            matrix.post ( "/client/r0/account/3pid/msisdn/requestToken", {
                client_secret: client_secret,
                country: matrix.countryCode,
                phone_number: desiredPhoneNumber,
                send_attempt: 1,
                id_server: matrix.id_server
            }, success_callback, success_callback)
        }
        else mainLayout.init ()

    }, function (error) {
        if ( error.errcode === "M_USER_IN_USE" ) toast.show (i18n.tr("Username already taken"))
        else if ( error.errcode === "M_INVALID_USERNAME" ) toast.show ( i18n.tr("The desired user ID is not a valid user name") )
        else if ( error.errcode === "M_EXCLUSIVE" ) toast.show ( i18n.tr("The desired user ID is in the exclusive namespace claimed by an application service") )
        else toast.show ( i18n.tr("Registration on %1 failed...").arg((loginDomain || defaultDomain)) )
    } )
}


function toggleHide () {
    if ( loginTextField.echoMode === TextInput.Normal ) {
        loginTextField.echoMode = TextInput.Password
    }
    else {
        loginTextField.echoMode = TextInput.Normal
    }
    loginTextField.focus = true
}
