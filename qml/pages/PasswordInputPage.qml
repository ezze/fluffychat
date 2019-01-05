import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    function login () {
        signInButton.enabled = false
        var _tabletMode = tabletMode
        var _toast = toast

        // If the login is successfull
        var success_callback = function ( response ) {
            signInButton.enabled = true
            // Go to the ChatListPage
            matrix.init()
        }

        // If error
        var error_callback = function ( error ) {
            signInButton.enabled = true
            if ( error.errcode == "M_FORBIDDEN" ) {
                root.toast.show ( i18n.tr("Invalid username or password") )
            }
            else {
                root.toast.show ( i18n.tr("No connection to ") + settings.server )
            }
        }

        // Start the request
        matrix.login ( settings.username, passwordInput.text, settings.server, "UbuntuPhone", success_callback, error_callback )
    }

    header: FcPageHeader {
        title: i18n.tr('Enter your password')
    }

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
                name: "user-admin"
                color: settings.mainColor
                width: root.width * 2/5
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: loginStatus
                text: i18n.tr("Please enter your password for: <b>%1</b>").arg(settings.matrixid)
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
                height: Math.max(scrollView.height - banner.height - loginStatus.height - passwordInput.height - signInButton.height - units.gu(9),0)
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
