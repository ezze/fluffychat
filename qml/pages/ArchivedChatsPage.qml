import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent
    id: archivedChatListPage

    property var searching: false


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
        newChatUpdate: update ()
    }

    header: FcPageHeader {
        id: header
        title: i18n.tr("Archived chats")

        trailingActionBar {
            actions: [
            Action {
                iconName: searching ? "close" : "search"
                onTriggered: {
                    searching = searchField.focus = !searching
                    if ( !searching ) searchField.text = ""
                }
            }]
        }
    }

    TextField {
        id: searchField
        objectName: "searchField"
        visible: searching
        anchors {
            top: header.bottom
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search chat names...")
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
        height: parent.height - header.height
        anchors.top: header.bottom
        anchors.topMargin: searching * (searchField.height + units.gu(2))
        delegate: ArchivedChatListItem {}
        model: ListModel { id: model }
    }
}
