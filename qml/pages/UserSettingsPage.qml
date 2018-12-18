import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        id: header
        title: activeChatDisplayName
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth

            Avatar {  // Useravatar
                id: avatarImage
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: userInfo
                anchors.horizontalCenter: parent.horizontalCenter
                text: activeChat
            }


            SettingsListItem {
                name: "Start chat"
                icon: "message-new"
                visible: true
                onClicked: {
                    mainStack.clear ()
                    mainStack.push(Qt.resolvedUrl("../pages/ChatListPage.qml"))
                    mainStack.push(Qt.resolvedUrl("../pages/ChatPage.qml"))
                }
            }

            SettingsListItem {
                name: "Close chat"
                icon: "close"
            }

            SettingsListItem {
                name: "Remove contact"
                icon: "delete"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/InfoPage.qml"))
            }

        }
    }
}
