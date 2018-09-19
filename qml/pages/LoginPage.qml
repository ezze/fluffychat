import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var loginDomain: ""

    function login () {

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
            }
            ]
        }

        trailingActionBar {
            actions: [
            Action {
                iconName: "ok"
                onTriggered: login()
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
            }

            Rectangle {
                width: parent.width
                height: Math.max(scrollView.height - banner.height - 2 * loginTextField.height - 2 * serverLabel.height - units.gu(8),0)
            }

            Label {
                id: serverLabel
                text: i18n.tr("Using the homeserver: ") + "<b>" + (loginDomain || defaultDomain) + "</b>"
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }


}
