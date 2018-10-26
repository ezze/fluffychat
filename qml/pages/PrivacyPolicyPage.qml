import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Privacy Policy')
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                wrapMode: Text.WordWrap
                text: i18n.tr("<br>" +
                "<b>Matrix client</b><br>" +
                "<br>" +
                "* Fluffychat is a matrix protocol client and compatible with all matrix servers and matrix identity servers. All communications made by the use while using fluffychat are done with the matrix server and the matrix identity server.<br>" +
                "* The default server is https://ubports.chat and the default identity server is https://vector.im.<br>" +
                "* Fluffychat doesn't operate any server or service.<br>" +
                "* All communications between fluffychat and any server is done in secure way, using encryption to protect it.<br>" +
                "* Fluffychat is not responsible for the data processing by any matrix server or matrix identity server.<br>" +
                "* Fluffychat offers the possibility to use phone numbers to find contacts. This is optional and no contacts are uploaded without user interaction! The user can choose, which contacts he want to upload to the identity server!<br>" +
                "<br>" +
                "<b>Push Notifications</b><br>" +
                "<br>" +
                "* The matrix server the user is using, will automatically send push notifications to the UBports push service. This notifications are encrypted with https on the way from the matrix server to the official ubports matrix gateway at https://push.ubports.com:5003/_matrix/push/r0/notify which forwards the notification to UBports push service at https://push.ubports.com and then sends this as a push notification to the user's device(s).<br>")
            }

        }
    }

}
