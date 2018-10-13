import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var loginDomain: ""

    function login () {
        loginAction.enabled = false
        var username = loginTextField.displayText
        desiredUsername = username

        // Step 1: Transforming the username:
        // If it is a normal username, then use the current domain
        // If it is a matrix-id, then get the infos from this form:
        // @username:domain
        if ( username.indexOf ("@") !== -1 ) {
            var usernameSplitted = username.substr(1).split ( ":" )
            username = usernameSplitted [0]
            loginDomain = usernameSplitted [1]
        }

        // Step 2: If there is no phone number, and the user is new then try to register the username
        if ( phoneTextField.displayText === "" && newHereCheckBox.checked ) register ( username )

        // Step 2.1: If there is no phone number and the user is not new, then check if user exists:
        else if  ( phoneTextField.displayText === "" ) {
            matrix.get( "/client/r0/register/available", {"username": username.toLowerCase() }, function ( response ) {
                if ( !response.available ) mainStack.push(Qt.resolvedUrl("./PasswordInputPage.qml"))
                else toast.show (i18n.tr("Username '%1' not found on %2").arg(username).arg(loginDomain))
            }, function ( response ) {
                if ( response.errcode === "M_USER_IN_USE" ) mainStack.push(Qt.resolvedUrl("./PasswordInputPage.qml"))
                else toast.show ( response.error )
            })
        }

        // Step 3: Try to get the username via the phone number and login
        else {
            // Transform the phone number
            var phoneInput = phoneTextField.displayText.replace(/\D/g,'')
            if ( phoneInput.charAt(0) === "0" ) phoneInput = phoneInput.substr(1)
            phoneInput = settings.countryTel + phoneInput

            // Step 3.1: Look for this phone number
            matrix.get ("/identity/api/v1/lookup", {
                "medium": "msisdn",
                "address": phoneInput
            }, function ( response ) {

                // Step 3.2: There is a registered matrix id. Go to the password input...
                if ( response.mxid ) {
                    var splittedMxid = response.mxid.substr(1).split ( ":" )
                    settings.username = splittedMxid[0]
                    settings.server = splittedMxid[1]
                    mainStack.push(Qt.resolvedUrl("./PasswordInputPage.qml"))
                }
                // Step 3.3.1: There is no registered matrix id and user is not new, so abbort!
                else if ( !newHereCheckBox.checked ) toast.show (i18n.tr("No user found with this phone number"))
                // Step 3.3.2: There is no registered matrix id. Try to register one...
                else {
                    desiredPhoneNumber = phoneInput
                    register ( username )
                }
            })
        }
        loginAction.enabled = loginTextField.displayText !== "" && loginTextField.displayText !== " "
    }

    function register ( username ) {
        matrix.get( "/client/r0/register/available", {"username": username.toLowerCase() }, function ( response ) {
            if ( response.available ) mainStack.push(Qt.resolvedUrl("./PasswordCreationPage.qml"))
            else toast.show (i18n.tr("Username is already taken"))
        }, function ( response ) {
            if ( response.errcode === "M_USER_IN_USE" ) toast.show (i18n.tr("Username is already taken"))
            else toast.show ( response.error )
        })
    }


    header: FcPageHeader {
        title: i18n.tr('Welcome to FluffyChat')

        leadingActionBar {
            numberOfSlots: 1
            actions: [

            Action {
                iconName: "sync-idle"
                text: i18n.tr("Change homeserver")
                onTriggered: PopupUtils.open(changeHomeserverDialog)
            },
            Action {
                iconName: "hotspot-connected"
                text: i18n.tr("Change ID-server")
                onTriggered: PopupUtils.open(changeIdentityserverDialog)
            },
            Action {
                iconName: "display-brightness-max"
                text: i18n.tr("Toggle dark mode")
                onTriggered: settings.darkmode = !settings.darkmode
            }
            ]
        }

        trailingActionBar {
            actions: [
            Action {
                id: loginAction
                iconName: "ok"
                onTriggered: login()
                enabled: loginTextField.displayText !== "" && loginTextField.displayText !== " "
            }
            ]
        }
    }

    Component {
        id: changeHomeserverDialog
        Dialog {
            id: dialogue
            title: i18n.tr("Choose your homeserver")
            TextField {
                id: homeserverInput
                placeholderText: defaultDomain
                text: loginDomain
                focus: true
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

    Component {
        id: changeIdentityserverDialog
        Dialog {
            id: dialogue
            title: i18n.tr("Choose your identity server")
            TextField {
                id: identityserverInput
                placeholderText: defaultIDServer
                text: settings.id_server === defaultIDServer ? "" : settings.id_server
                focus: true
            }
            Button {
                text: "OK"
                onClicked: {
                    settings.id_server = identityserverInput.displayText.toLowerCase()
                    PopupUtils.close(dialogue)
                }
            }
        }
    }

    property var elemWidth: Math.min( parent.width - units.gu(4), units.gu(50))

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
                source: "../../assets/fluffychat-banner.png"
                color: settings.mainColor
                width: root.width
                height: width * 2/5
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    color: UbuntuColors.green
                    width: units.gu(8)
                    text: settings.countryCode + " +%1".arg(settings.countryTel)
                    onClicked: {
                        var item = Qt.createComponent("../components/CountryPicker.qml")
                        item.createObject(mainStack.currentPage, { })
                    }
                }
                TextField {
                    id: phoneTextField
                    placeholderText: i18n.tr("Phone number (optional)")
                    Keys.onReturnPressed: loginTextField.focus = true
                    inputMethodHints: Qt.ImhDigitsOnly
                    width: elemWidth - units.gu(8)
                }
            }
            TextField {
                anchors.horizontalCenter: parent.horizontalCenter
                id: loginTextField
                placeholderText: i18n.tr("Username")
                Keys.onReturnPressed: login()
                width: elemWidth
                onDisplayTextChanged: {
                    if ( displayText.indexOf ("@") !== -1 ) {
                        var usernameSplitted = displayText.substr(1).split ( ":" )
                        loginDomain = usernameSplitted [1]
                    }
                }
            }
            Row {
                id: newHere
                width: loginTextField.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1)
                CheckBox {
                    id: newHereCheckBox
                    checked: true
                    width: units.gu(3)
                    height: width
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("I'm new here")
                }
            }

            Rectangle {
                width: parent.width
                color: theme.palette.normal.background
                height: Math.max(scrollView.height - newHere.height - banner.height - 2 * loginTextField.height - 2 * serverLabel.height - units.gu(9),0)
            }

            Label {
                id: serverLabel
                text: i18n.tr("Using the homeserver: ") + "<b>" + (loginDomain || defaultDomain) + "</b>"
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }


}
