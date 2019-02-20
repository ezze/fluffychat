import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    id: passwordCreationPage
    anchors.fill: parent

    property var loginDomain: ""

    property var sid: null
    property var client_secret: null


    Component.onCompleted: {
        // If there is a desired phone number, try to register it now:

    }


    EnterFirstSMSTokenDialog { id: enterSMSToken }


    header: FcPageHeader {
        title: i18n.tr("Please set a password")
    }

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
                    country: settings.countryCode,
                    phone_number: desiredPhoneNumber,
                    send_attempt: 1,
                    id_server: settings.id_server
                }, success_callback, success_callback)
            }
            else root.init ()

        }, function (error) {
            if ( error.errcode === "M_USER_IN_USE" ) toast.show (i18n.tr("Username already taken"))
            else if ( error.errcode === "M_INVALID_USERNAME" ) toast.show ( i18n.tr("The desired user ID is not a valid user name") )
            else if ( error.errcode === "M_EXCLUSIVE" ) toast.show ( i18n.tr("The desired user ID is in the exclusive namespace claimed by an application service") )
            else toast.show ( i18n.tr("Registration on %1 failed...").arg((loginDomain || defaultDomain)) )
        } )
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
                    Keys.onReturnPressed: register ()
                }
                Button {
                    id: hideButton
                    color: UbuntuColors.porcelain
                    width: units.gu(6)
                    iconName: loginTextField.echoMode === TextInput.Normal ? "private-browsing" : "private-browsing-exit"
                    onClicked: {
                        loginTextField.echoMode === TextInput.Normal ? loginTextField.echoMode = TextInput.Password : loginTextField.echoMode = TextInput.Normal
                        loginTextField.focus = true
                    }
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
                onClicked: register ()
                enabled: loginTextField.text !== ""
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }

}
