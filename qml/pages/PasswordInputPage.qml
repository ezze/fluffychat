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
            okAction.enabled = true
            // Go to the ChatListPage
            mainStack.clear ()
            if ( tabletMode ) mainStack.push(Qt.resolvedUrl("./BlankPage.qml"))
            else mainStack.push(Qt.resolvedUrl("./ChatListPage.qml"))
        }

        // If error
        var error_callback = function ( error ) {
            okAction.enabled = true
            if ( error.errcode == "M_FORBIDDEN" ) {
                toast.show ( i18n.tr("Invalid username or password") )
            }
            else {
                toast.show ( i18n.tr("No connection to ") + settings.server )
            }
        }

        // Start the request
        matrix.login ( settings.username, passwordInput.text, settings.server, "UbuntuPhone", success_callback, error_callback )
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
                text: i18n.tr("Please enter your password for: <b>%1</b>").arg(matrix.matrixid)
                width: Math.min( parent.width - units.gu(4), units.gu(50))
                wrapMode: Text.Wrap
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
        }
    }
}
