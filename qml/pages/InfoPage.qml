import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

Page {
    id: infoPage
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Info about FluffyChat %1 on %2').arg(version).arg(Qt.platform.os)
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
                name: i18n.tr("Become a patron")
                icon: "like"
                iconColor: UbuntuColors.red
                onClicked: Qt.openUrlExternally("https://www.patreon.com/krillechritzelius")
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
                onClicked: MatrixNames.showCommunity("+ubports_community:matrix.org")
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
                onClicked: Qt.openUrlExternally("https://christianpauly.github.io/fluffychat")
            }

            SettingsListItem {
                name: i18n.tr("Contributors")
                icon: "contact-group"
                onClicked: Qt.openUrlExternally("https://github.com/ChristianPauly/fluffychat/graphs/contributors")
            }

            SettingsListItem {
                name: i18n.tr("Source code")
                icon: "text-xml-symbolic"
                onClicked: Qt.openUrlExternally("https://github.com/ChristianPauly/fluffychat")
            }

            SettingsListItem {
                name: i18n.tr("License")
                icon: "x-office-document-symbolic"
                onClicked: Qt.openUrlExternally("https://github.com/ChristianPauly/fluffychat/blob/master/LICENSE")
            }

        }
    }

}
