import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    id: infoPage
    anchors.fill: parent

    header: PageHeader {
        title: i18n.tr('FluffyChat %1 on %2').arg(version).arg(platform)
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: infoPage.width

            Image {
                id: coffeeImage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: parent.width / 4
                width: parent.width / 2
                height: width
                source: "../../assets/info-logo.svg"
            }

            SettingsListItem {
                name: i18n.tr("Buy a coffee for me")
                icon: "like"
                iconColor: UbuntuColors.red
                onClicked: Qt.openUrlExternally("https://ko-fi.com/krille")
            }

            SettingsListItem {
                name: i18n.tr("Support on Liberapay")
                icon: "like"
                iconColor: mainLayout.mainColor
                onClicked: Qt.openUrlExternally("https://liberapay.com/KrilleChritzelius")
            }

            SettingsListItem {
                name: i18n.tr("Join the community")
                icon: "contact-group"
                onClicked: bottomEdgePageStack.push ( Qt.resolvedUrl ("../pages/CommunityPage.qml" ), { activeCommunity: "+ubports_community:matrix.org" } )
            }

            SettingsListLink {
                name: i18n.tr("Privacy Policy")
                icon: "private-browsing"
                page: "PrivacyPolicyPage"
                sourcePage: infoPage
            }

            SettingsListItem {
                name: i18n.tr("Website")
                icon: "external-link"
                onClicked: Qt.openUrlExternally("https://christianpauly.gitlab.io/fluffychat-website")
            }

            SettingsListItem {
                name: i18n.tr("Contributors")
                icon: "contact-group"
                onClicked: Qt.openUrlExternally("https://gitlab.com/ChristianPauly/fluffychat/graphs/master")
            }

            SettingsListItem {
                name: i18n.tr("Source code")
                icon: "text-xml-symbolic"
                onClicked: Qt.openUrlExternally("https://gitlab.com/ChristianPauly/fluffychat")
            }

            SettingsListItem {
                name: i18n.tr("License")
                icon: "x-office-document-symbolic"
                onClicked: Qt.openUrlExternally("https://gitlab.com/ChristianPauly/fluffychat/blob/master/LICENSE")
            }

        }
    }

}
