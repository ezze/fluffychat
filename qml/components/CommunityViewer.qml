import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

BottomEdge {

    id: communityViewer
    height: parent.height - parent.header.height

    onCollapseCompleted: communityViewer.destroy ()
    Component.onCompleted: commit()

    contentComponent: Page {
            height: communityViewer.height

            StyledPageHeader {
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
                        onTriggered: shareController.shareTextIntern ( activeCommunity )
                    }
                    ]
                }
            }

            Component.onCompleted: {
                matrix.get ( "/client/r0/groups/%1/profile".arg(activeCommunity), null, function (res) {
                    communityHeader.title = res.name
                    avatar.mxc = res.avatar_url
                    communityInfo.text = sender.formatText(res.short_description)
                } )
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
                height: communityViewer.height - communityHeader.height
                anchors.top: communityHeader.bottom
                contentItem: Column {
                    width: communityViewer.width

                    Avatar {
                        id: avatar
                        width: parent.width
                        height: width * 10/16
                        name: activeCommunity
                        anchors.horizontalCenter: parent.horizontalCenter
                        mxc: ""
                        radius: 0
                        onClickFunction: function () {
                            if ( mxc !== "" ) {
                                communityViewer.collapse ()
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
                            linkColor: settings.brightMainColor
                            textFormat: Text.StyledText
                            onLinkActivated: uriController.openUrlExternally ( link )
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
}
