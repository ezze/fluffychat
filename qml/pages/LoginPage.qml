import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var loginDomain: defaultDomain

    function login () {
        loginButton.enabled = false
        var username = loginTextField.displayText
        var password = passwordTextField.text
        // Check if the Textfields are filled
        if ( username === "" || password === "" ) {
            loginButton.enabled = true
            loginStatus.text = i18n.tr("Please fill all textfields")
            return
        }
        // Transforming the username:
        // If it is a normal username, then use the current domain
        // If it is a matrix-id, then get the infos from this form:
        // @username:domain
        if ( username.indexOf ("@") !== -1 ) {
            var usernameSplitted = username.substr(1).split ( ":" )
            username = usernameSplitted [0]
            loginDomain = usernameSplitted [1]
        }

        // If the login is successfull
        var success_callback = function ( response ) {
            loginButton.enabled = true
            // Go to the ChatListPage
            mainStack.clear ()
            if ( tabletMode ) mainStack.push(Qt.resolvedUrl("./BlankPage.qml"))
            else mainStack.push(Qt.resolvedUrl("./ChatListPage.qml"))
        }

        // If error
        var error_callback = function ( error ) {
            loginButton.enabled = true
            if ( error.errcode == "M_FORBIDDEN" ) {
                loginStatus.text = i18n.tr("Invalid username or password")
            }
            else {
                loginStatus.text = i18n.tr("No connection to ") + loginDomain
            }
        }

        // Start the request
        matrix.login ( username, password, loginDomain, "UbuntuPhone", success_callback, error_callback )
    }


    header: FcPageHeader {
        title: i18n.tr('Welcome to FluffyChat')

        trailingActionBar {
            actions: [
            Action {
                iconName: "settings"
                onTriggered: PopupUtils.open(dialog)
            }
            ]
        }
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Choose your homeserver")
            TextField {
                id: homeserverInput
                placeholderText: defaultDomain
                text: loginDomain
            }
            Button {
                text: "OK"
                onClicked: {
                    loginDomain = homeserverInput.displayText.toLowerCase()
                    PopupUtils.close(dialogue)
                }
            }
        }
    }

    Column {
        id: loginColumn
        anchors.centerIn: parent
        width: parent.width
        spacing: loginStatus.height
        Label {
            id: loginStatus
            text: i18n.tr("What's your name?")
            textSize: Label.Large
            anchors.horizontalCenter: parent.horizontalCenter
        }

        TextField {
            id: loginTextField
            placeholderText: i18n.tr("Username")
            anchors.horizontalCenter: parent.horizontalCenter
            Keys.onReturnPressed: passwordTextField.focus = true
        }

        TextField {
            id: passwordTextField
            placeholderText: i18n.tr("Password")
            echoMode: TextInput.Password
            anchors.horizontalCenter: parent.horizontalCenter
            Keys.onReturnPressed: login ()
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu("2")
            Button {
                id: loginButton
                text: i18n.tr("Sign in")
                color: UbuntuColors.green
                onClicked: login ()
                enabled: loginTextField.displayText !== "" && passwordTextField.displayText !== ""
            }
            Button {
                id: registerButton
                text: i18n.tr("Sign up")
                onClicked: Qt.openUrlExternally( "https://" + loginDomain + "/_matrix/client/#/register")
            }
        }


    }

    Label {
        text: i18n.tr("Using the homeserver: ") + loginDomain
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: height
    }



}
