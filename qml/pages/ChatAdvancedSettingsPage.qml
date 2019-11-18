import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/ChatAdvancedSettingsPageActions.js" as PageActions

Page {
    id: chatPrivacySettingsPage
    anchors.fill: parent

    property var ownPower
    property var canChangePermissions: false
    property var canChangeAccessRules: false
    property var canChangeHistoryRules: false

    property var powerLevelDescription: ""
    property var activePowerLevel: ""

    Component.onCompleted: PageActions.init ()

    Connections {
        target: matrix
        onNewEvent: PageActions.update ( type, chat_id, eventType, eventContent )
    }

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
        title:  i18n.tr('Advanced settings')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: chatPrivacySettingsPage.width

            ListSeperator {
                text: i18n.tr("End-to-end encryption")
            }

            SettingsListLink {
                id: initEncryption
                name: i18n.tr("Encryption settings")
                icon: "lock"
                page: "ChatDevicesPage"
                sourcePage: chatPrivacySettingsPage
            }

            ListSeperator {
                text: i18n.tr("Access")
            }

            SettingsListSwitch {
                id: invitedAllowed
                name: i18n.tr("Users can be invited")
                icon: "contact-new"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeAccessRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchInvitedAllowed( isChecked )
            }

            SettingsListSwitch {
                id: chatIsPublic
                name: i18n.tr("Chat is public accessible")
                icon: "lock-broken"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeAccessRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchChatIsPublic( isChecked )
            }

            SettingsListSwitch {
                id: guestsAllowed
                name: i18n.tr("Guest users are allowed")
                icon: "private-browsing"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeAccessRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchGuestsAllowed ()
            }

            SettingsListLink {
                name: i18n.tr("Public chat addresses")
                icon: "stock_link"
                page: "ChatAliasSettingsPage"
                sourcePage: chatPrivacySettingsPage
            }

            ListSeperator {
                text: i18n.tr("History visibility")
            }

            SettingsListSwitch {
                id: invitedHistoryAccess
                name: i18n.tr("History is visible from invitation")
                icon: "user-admin"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeHistoryRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchInvitedHistoryAccess ( isChecked )
            }
            SettingsListSwitch {
                id: sharedHistoryAccess
                name: i18n.tr("Members can access full chat history")
                icon: "stock_ebook"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeHistoryRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchSharedHistoryAccess ( isChecked )
            }
            SettingsListSwitch {
                id: worldHistoryAccess
                name: i18n.tr("Anyone can access full chat history")
                icon: "stock_website"
                isEnabled: matrix.waitingForAnswer === 0 && canChangeHistoryRules
                switcher.onCheckedChanged: if ( switcher.enabled ) PageActions.switchWorldHistoryAccess ( isChecked )
            }
        }
    }
}
