import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent
    id: archivedChatListPage

    property var searching: true


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    Component.onCompleted: update ()

    function update () {

        // On the top are the rooms, which the user is invited to
        storage.transaction ("SELECT rooms.id, rooms.topic, rooms.avatar_url " +
        " FROM Chats rooms " +
        " WHERE rooms.membership='leave' " +
        " ORDER BY rooms.topic DESC "
        , function(res) {
            model.clear ()
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                // We request the room name, before we continue
                model.append ( { "room": room } )
            }
        })
    }


    Connections {
        target: events
        onNewChatUpdate: update ()
    }

    header: FcPageHeader {
        id: header
        title: i18n.tr("Archived chats")

        flickable: chatListView

        extension: Rectangle {
            width: parent.width
            height: searchField.height + units.gu(1)
            color: theme.palette.normal.background
            anchors.bottom: parent.bottom
            TextField {
                id: searchField
                objectName: "searchField"
                primaryItem: Icon {
                    height: parent.height - units.gu(2)
                    name: "find"
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(0.25)
                }
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    rightMargin: units.gu(2)
                    leftMargin: units.gu(2)
                }
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Search chat names...")
            }
        }
    }




    Label {
        id: loadingLabel
        anchors.centerIn: chatListView
        text: i18n.tr("There are no archived chats")
        visible: model.count === 0
    }


    ListView {
        id: chatListView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        delegate: ArchivedChatListItem {}
        model: ListModel { id: model }
    }
}
