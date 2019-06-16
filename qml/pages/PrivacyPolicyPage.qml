import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    id: privacyPolicyPage
    anchors.fill: parent

    header: PageHeader {
        title: i18n.tr('Privacy Policy')
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: privacyPolicyPage.width

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                wrapMode: Text.WordWrap
                text: i18n.tr("<br>" +
                "<b>Matrix client</b><br>" +
                "<br>" +
                "* FluffyChat is a Matrix protocol client and is compatible with all Matrix servers and Matrix identity servers. All communications conducted while using FluffyChat use a Matrix server and the Matrix identity server.<br>" +
                "* The default server in FluffyChat is https://matrix.org and the default identity server is https://vector.im.<br>" +
                "* FluffyChat doesn't operate any server or remote service.<br>" +
                "* All communication of substantive content between FluffyChat and any server is done in secure way, using transport encryption to protect it. End-to-end encryption will follow.<br>" +
                "* FluffyChat is not responsible for the data processing carried out by any Matrix server or Matrix identity server.<br>" +
                "* FluffyChat offers the option to use phone numbers to find contacts. This is not a requirement of normal operation and is intended only as a convenience. No contact details are uploaded without user interaction! The user can choose to upload all or some or no contacts to the identity server!<br>" +
                "<br>" +
                "<b>Push Notifications</b><br>" +
                "<br>" +
                "* The Matrix server selected by the user will automatically send push notifications to the UBports push service. These notifications are encrypted with the https protocol between the device and the Matrix server and on to the official UBports Matrix gateway at https://push.ubports.com:5003/_matrix/push/r0/notify This server forwards the notification to UBports push service at https://push.ubports.com and then sends this on as a push notification to the user's device(s).<br>")
            }

        }
    }

}
