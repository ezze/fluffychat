import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    id: passwordInputPage
    anchors.fill: parent

    function login () {
        signInButton.enabled = false

        // If the login is successfull
        var success_callback = function ( response ) {
            signInButton.enabled = true
            // Go to the ChatListPage
            mainLayout.init()
        }

        // If error
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
        matrix.login ( matrix.username, passwordInput.text, matrix.server, "UbuntuPhone", success_callback, error_callback )
    }

    header: PageHeader {
        title: i18n.tr('Enter your password')
    }

    ScrollView {
        id: scrollView
        width: passwordInputPage.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: passwordInputPage.width
            spacing: units.gu(2)

            Rectangle {
                id: bannerRect
                width: parent.width
                height: (passwordInputPage.height - header.height)/2 - (3 * passwordInput.height) - units.gu(4)
                Icon {
                    id: banner
                    name: "user-admin"
                    anchors.centerIn: parent
                    width: units.gu(6)
                    height: width
                }
            }


            Label {
                id: loginStatus
                text: i18n.tr("Please enter your password for: <b>%1</b>").arg(matrix.username)
                width: Math.min( parent.width - units.gu(4), units.gu(50))
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: passwordInput
                placeholderText: i18n.tr("Password...")
                anchors.horizontalCenter: parent.horizontalCenter
                echoMode: TextInput.Password
                width: Math.min( parent.width - units.gu(4), units.gu(50))
                Keys.onReturnPressed: login()
                Component.onCompleted: focus = true
            }

            Rectangle {
                width: parent.width
                color: theme.palette.normal.background
                height: Math.max(scrollView.height - bannerRect.height - loginStatus.height - passwordInput.height - signInButton.height - units.gu(9),0)
            }

            Button {
                id: signInButton
                text: i18n.tr("Sign in")
                width: passwordInput.width
                color: UbuntuColors.green
                onClicked: login()
                enabled: passwordInput.text !== ""
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
