import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

Page {
    id: loginPage
    anchors.fill: parent

    property var loginDomain: ""

    property var domainChanged: false

    function login () {
        if ( loginDomain === "" ) loginDomain = defaultDomain
        signInButton.enabled = false
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
        settings.username = username
        settings.server = loginDomain

        // Step 2: If there is no phone number, and the user is new then try to register the username
        if ( phoneTextField.displayText === "" && newHereCheckBox.checked ) register ( username )

        // Step 2.1: If there is no phone number and the user is not new, then check if user exists:
        else if  ( phoneTextField.displayText === "" ) {
            matrix.get( "/client/r0/register/available", {"username": username.toLowerCase() }, function ( response ) {
                if ( !response.available ) mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("./PasswordInputPage.qml") )
                else toast.show (i18n.tr("Username '%1' not found on %2").arg(username).arg(loginDomain))
            }, function ( response ) {
                if ( response.errcode === "M_USER_IN_USE" ) mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("./PasswordInputPage.qml") )
                else if ( response.error === "CONNERROR" ) toast.show (i18n.tr("😕 No connection..."))
                else toast.show ( response.error )
            }, 2)
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
                    mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("./PasswordInputPage.qml") )
                }
                // Step 3.3.1: There is no registered matrix id. Try to register one...
                else {
                    console.log("Step 3.3.1: There is no registered matrix id. Try to register one...")
                    desiredPhoneNumber = phoneInput
                    register ( username )
                }
            }, null, 2)
        }
        signInButton.enabled = loginTextField.displayText !== "" && loginTextField.displayText !== " "
    }

    function register ( username ) {
        matrix.get( "/client/r0/register/available", {"username": username.toLowerCase() }, function ( response ) {
            if ( response.available ) mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("./PasswordCreationPage.qml") )
            else toast.show (i18n.tr("Username is already taken"))
        }, function ( response ) {
            if ( response.errcode === "M_USER_IN_USE" ) toast.show (i18n.tr("Username is already taken"))
            else if ( response.error === "CONNERROR" ) toast.show (i18n.tr("😕 No connection..."))
            else toast.show ( response.error )
        }, 2)
    }

    Component.onCompleted: if ( settings.darkmode ) settings.darkmode = false

    header: FcPageHeader {
        title: i18n.tr('Homeserver %1').arg( (loginDomain || defaultDomain) )

        leadingActionBar {
            numberOfSlots: 1
            actions: [

            Action {
                iconName: "sync-idle"
                text: i18n.tr("Change homeserver")
                onTriggered: {
                    domainChanged = true
                    PopupUtils.open(changeHomeserverDialog)
                }
            },
            Action {
                iconName: "hotspot-connected"
                text: i18n.tr("Change ID-server")
                onTriggered: PopupUtils.open(changeIdentityserverDialog)
            },
            Action {
                iconName: "info"
                text: i18n.tr("About FluffyChat")
                onTriggered: mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("./InfoPage.qml") )
            },
            Action {
                iconName: "private-browsing"
                text: i18n.tr("Privacy Policy")
                onTriggered: mainLayout.addPageToCurrentColumn ( mainLayout.primaryPage, Qt.resolvedUrl("./PrivacyPolicyPage.qml") )
            }
            ]
        }

        trailingActionBar {
            actions: [
            Action {
                iconName: "help"
                text: i18n.tr("FAQ")
                onTriggered: Qt.openUrlExternally("https://christianpauly.github.io/fluffychat/faq.html")
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
                    if ( homeserverInput.displayText === "" ) loginDomain = defaultDomain
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
                    if ( identityserverInput.displayText === "" ) settings.id_server = defaultIDServer
                    else settings.id_server = identityserverInput.displayText.toLowerCase()
                    PopupUtils.close(dialogue)
                }
            }
        }
    }

    property var elemWidth: Math.min( loginPage.width - units.gu(4), units.gu(50))

    ScrollView {
        id: scrollView
        width: loginPage.width
        height: parent.height - header.height
        flickableItem.contentY: flickableItem.contentHeight - height
        anchors.top: header.bottom
        contentItem: Column {
            width: loginPage.width
            spacing: units.gu(2)

            Icon {
                id: banner
                source: "../../assets/fluffychat-banner.png"
                color: settings.mainColor
                width: height * 5/2
                height: Math.max( (loginPage.height - header.height)/2 - 4 * loginTextField.height - units.gu(4), (elemWidth+units.gu(4))*2/5 )
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    width: units.gu(8)
                    text: settings.countryCode + " +%1".arg(settings.countryTel)
                    onClicked: {
                        var item = Qt.createComponent("../components/CountryPicker.qml")
                        item.createObject( root, { })
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
                placeholderText: i18n.tr("Username or Matrix ID")
                Keys.onReturnPressed: login()
                width: elemWidth
                onDisplayTextChanged: {
                    if ( displayText.indexOf ("@") !== -1 && !domainChanged ) {
                        var usernameSplitted = displayText.substr(1).split ( ":" )
                        loginDomain = usernameSplitted [1]
                    }
                }
            }

            Rectangle {
                id: spacerRect
                width: parent.width
                color: theme.palette.normal.background
                height: Math.max(scrollView.height - banner.height - 2 * loginTextField.height - (newHere.visible * (newHere.height + units.gu(2))) - signInButton.height - units.gu(10), 0)
            }

            Row {
                id: newHere
                visible: phoneTextField.displayText === "" && loginTextField.displayText !== ""
                opacity: 0
                width: loginTextField.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1)
                states: State {
                    name: "visible"; when: newHere.visible
                    PropertyChanges {
                        target: newHere
                        opacity: 1
                    }
                }
                transitions: Transition {
                    NumberAnimation { property: "opacity"; duration: 300 }
                }
                CheckBox {
                    id: newHereCheckBox
                    checked: false
                    width: units.gu(2)
                    height: width
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Create a new account")
                }
            }

            Button {
                id: signInButton
                text: newHereCheckBox.checked && newHereCheckBox.visible ? i18n.tr("Sign up") : i18n.tr("Sign in")
                width: loginTextField.width
                color: UbuntuColors.green
                onClicked: login()
                enabled: loginTextField.displayText !== ""
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                color: theme.palette.normal.background
                height: 0.00001
            }

        }
    }


}
