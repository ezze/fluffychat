import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/PasswordCreationPageActions.js" as PageStack

StyledPage {
    id: passwordCreationPage
    anchors.fill: parent

    property var loginDomain: ""

    property var sid: null
    property var client_secret: null


    EnterFirstSMSTokenDialog { id: enterSMSToken }


    header: PageHeader {
        title: i18n.tr("Please set a password")
    }

    property var elemWidth: Math.min( parent.width - units.gu(4), units.gu(50))

    ScrollView {
        id: scrollView
        width: passwordCreationPage.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            id: column
            width: passwordCreationPage.width
            spacing: units.gu(2)

            Rectangle {
                id: bannerRect
                width: parent.width
                height: (passwordCreationPage.height - header.height)/2 - (3 * loginTextField.height) - units.gu(4)
                Icon {
                    id: banner
                    name: "lock"
                    anchors.centerIn: parent
                    width: units.gu(6)
                    height: width
                }
            }

            Label {
                id: loginStatus
                text: i18n.tr("Please set a strong password. To reset your password, you will need to provide an e-mail address later")
                width: elemWidth
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                id: row
                height: loginTextField.height
                width: elemWidth
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    echoMode: TextInput.Normal
                    id: loginTextField
                    width: parent.width - hideButton.width
                    placeholderText: i18n.tr("e.g. Summer%salad$flattens?tOOthpaste")
                    Component.onCompleted: focus = true
                    Keys.onReturnPressed: PageActions.register ()
                }
                Button {
                    id: hideButton
                    color: UbuntuColors.porcelain
                    width: units.gu(6)
                    iconName: loginTextField.echoMode === TextInput.Normal ? "private-browsing" : "private-browsing-exit"
                    onClicked: PageActions.toggleHide ()
                }
            }

            Rectangle {
                width: parent.width
                color: theme.palette.normal.background
                height: Math.max(scrollView.height - bannerRect.height - loginStatus.height - row.height - signInButton.height - units.gu(9),0)
            }

            Button {
                id: signInButton
                text: i18n.tr("Sign up")
                width: row.width
                color: UbuntuColors.green
                onClicked: PageActions.register ()
                enabled: loginTextField.text !== ""
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }

}
