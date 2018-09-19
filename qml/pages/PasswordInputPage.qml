import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    function login () {
        okAction.enabled = false

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
        matrix.login ( settings.username, passwordInput.displayText, settings.server, "UbuntuPhone", success_callback, error_callback )
    }

    header: FcPageHeader {
        title: i18n.tr('Enter your password')

        trailingActionBar {
            actions: [
            Action {
                id: okAction
                iconName: "ok"
                onTriggered: login()
                enabled: passwordInput.displayText !== ""
            }
            ]
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

            Label {
                id: loginStatus
                text: i18n.tr("Please enter your password for:\n<b>%1</b>").arg(matrix.matrixid)
                textSize: Label.Large
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: passwordInput
                placeholderText: i18n.tr("Password...")
                anchors.horizontalCenter: parent.horizontalCenter
                focus: true
                echoMode: TextInput.Password
                Keys.onReturnPressed: login()
            }




        }

    }
