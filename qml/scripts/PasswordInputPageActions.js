// File: PasswordInputPageActions.js
// Description: Actions for PasswordInputPage.qml

function login () {
    signInButton.enabled = false

    var error_callback = function ( error ) {
        signInButton.enabled = true
        if ( error.errcode == "M_FORBIDDEN" ) {
            toast.show ( i18n.tr("Invalid username or password") )
        }
        else {
            toast.show ( i18n.tr("No connection to ") + matrix.server )
        }
    }

    // Start the request
    matrix.login ( matrix.username, passwordInput.text, matrix.server, root.deviceName, null, error_callback )
}
