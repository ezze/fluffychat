import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/LoginPageActions.js" as LoginPageActions

Page {
    id: loginPage
    anchors.fill: parent

    property var loginDomain: ""

    property var domainChanged: false

    Component.onCompleted: mainLayout.darkmode = false

    header: PageHeader {
        title: i18n.tr('Homeserver %1').arg( (loginDomain || defaultDomain) )

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
                iconName: "info"
                text: i18n.tr("About FluffyChat")
                onTriggered: mainLayout.addPageToCurrentColumn ( loginPage, Qt.resolvedUrl("./InfoPage.qml") )
            },
            Action {
                iconName: "private-browsing"
                text: i18n.tr("Privacy Policy")
                onTriggered: mainLayout.addPageToCurrentColumn ( loginPage, Qt.resolvedUrl("./PrivacyPolicyPage.qml") )
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
                onClicked: LoginPageActions.changeHomeServer ( homeserverInput, dialogue )
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
                text: matrix.id_server === defaultIDServer ? "" : matrix.id_server
                focus: true
            }
            Button {
                text: "OK"
                onClicked: LoginPageActions.changeIDServer ( identityserverInput, dialogue )
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
                color: mainLayout.mainColor
                width: height * 5/2
                height: Math.max( (loginPage.height - header.height)/2 - 4 * loginTextField.height - units.gu(4), (elemWidth+units.gu(4))*2/5 )
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    width: units.gu(8)
                    text: matrix.countryCode + " +%1".arg(matrix.countryTel)
                    onClicked: LoginPageActions.showCountryPicker ()
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
                Keys.onReturnPressed: LoginPageActions.login()
                width: elemWidth
                onDisplayTextChanged: LoginPageActions.updateHomeServerByTextField ( displayText )
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
                onClicked: LoginPageActions.login()
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
