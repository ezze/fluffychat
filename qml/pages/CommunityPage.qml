import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"
import "../scripts/MessageFormats.js" as MessageFormats

Page {
    id: communityPage

    property string activeCommunity

    header: PageHeader {
        id: communityHeader
        title: activeCommunity

        trailingActionBar {
            actions: [
            Action {
                iconName: "settings"
                onTriggered: Qt.openUrlExternally("https://www.ubports.chat/#/group/%1".arg(activeCommunity))
            },
            Action {
                iconName: "mail-forward"
                onTriggered: contentHub.shareTextIntern ( activeCommunity )
            }
            ]
        }
    }

    Component.onCompleted: {
        matrix.get ( "/client/r0/groups/%1/profile".arg(activeCommunity), null, function (res) {
            communityHeader.title = res.name
            avatar.mxc = res.avatar_url
            communityInfo.text = MessageFormats.formatText(res.short_description)
        }, null, 2 )
        matrix.get ( "/client/r0/groups/%1/rooms".arg(activeCommunity), null, function (res) {
            var rooms = res.chunk
            for ( var i = 0; i < rooms.length; i++ ) {
                // We request the room name, before we continue
                var item = Qt.createComponent("../components/SimpleChatListItem.qml")
                item.createObject(chatListView, {
                    "room": {
                        id: rooms[i].room_id,
                        notification_count: 0,
                        eventsid: null,
                        topic: rooms[i].name,
                        avatar_url: rooms[i].avatar_url,
                        typing: []
                    }
                })
            }
        } )
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - communityHeader.height
        anchors.top: communityHeader.bottom
        contentItem: Column {
            width: communityPage.width

            Avatar {
                id: avatar
                width: parent.width
                height: width * 10/16
                name: activeCommunity
                anchors.horizontalCenter: parent.horizontalCenter
                mxc: ""
                relativeRadius: 0
                onClickFunction: function () {
                    if ( mxc !== "" ) {
                        bottomEdgePageStack.pop ()
                        imageViewer.show ( mxc )
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.ash
                visible: communityInfo.text !== ""
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: Qt.rgba(0,0,0,0)
                visible: communityInfo.text !== ""
            }
            Rectangle {
                width: parent.width
                height: communityInfo.height
                color: Qt.rgba(0,0,0,0)
                visible: communityInfo.text !== ""
                Label {
                    id: communityInfo
                    width: parent.width - units.gu(4)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("No description found")
                    wrapMode: Text.Wrap
                    linkColor: mainLayout.brightMainColor
                    textFormat: Text.StyledText
                    onLinkActivated: contentHub.openUrlExternally ( link )
                }
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: Qt.rgba(0,0,0,0)
                visible: communityInfo.text !== ""
            }

            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.ash
            }

            Column {
                id: chatListView
                width: parent.width
            }

        }
    }
}
