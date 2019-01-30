import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent
    id: chatListPage


    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    Component.onCompleted: {

        // On the top are the rooms, which the user is invited to
        storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, rooms.highlight_count, rooms.avatar_url, rooms.unread, " +
        " events.id AS eventsid, ifnull(events.origin_server_ts, DateTime('now')) AS origin_server_ts, events.content_body, events.sender, events.state_key, events.content_json, events.type " +
        " FROM Chats rooms LEFT JOIN Events events " +
        " ON rooms.id=events.chat_id " +
        " WHERE rooms.membership!='leave' " +
        " AND (events.origin_server_ts IN (" +
        " SELECT MAX(origin_server_ts) FROM Events WHERE chat_id=rooms.id " +
        // " AND type='m.room.message' " +
        ") OR rooms.membership='invite')" +
        " GROUP BY rooms.id " +
        " ORDER BY origin_server_ts DESC "
        , function(res) {
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                var body = room.content_body || ""
                room.content = JSON.parse(room.content_json)
                if ( room.type !== "m.room.message" ) {
                    room.content_body = displayEvents.getDisplay ( room )
                }
                // We request the room name, before we continue
                model.append ( { "room": room } )
            }
        })
    }


    /* When the app receives a new synchronization object, the chat list should be
    * updated, without loading it new from the database. There are several types
    * of changes:
    * - Join a new chat
    * - Invited to a chat
    * - Leave a chat
    * - New message in the last-message-field ( Which needs reordering the chats )
    * - Update the counter of unseen messages
    */
    function newChatUpdate ( chat_id, membership, notification_count, highlight_count, limitedTimeline ) {
        // Update the chat list item.
        // Search the room in the model
        var j = 0
        for ( j = 0; j < model.count; j++ ) {
            if ( model.get(j).room.id === chat_id ) break
        }

        // Does the chat already exist in the list model?
        if ( j === model.count && membership !== "leave" ) {
            var position = membership === "invite" ? 0 : j
            var timestamp = membership === "invite" ? new Date().getTime() : 0
            // Add the new chat to the list
            var newRoom = {
                "id": chat_id,
                "topic": "",
                "membership": membership,
                "highlight_count": highlight_count,
                "notification_count": notification_count,
                "origin_server_ts": timestamp
            }
            model.insert ( position, { "room": newRoom } )
        }
        // If the membership is "leave" then remove the item and stop here
        else if ( j !== model.count && membership === "leave" ) model.remove( j )
        else if ( membership !== "leave" ){
            // Update the rooms attributes:
            var tempRoom = model.get(j).room
            tempRoom.membership = membership
            tempRoom.notification_count = notification_count
            tempRoom.highlight_count = highlight_count
            model.set ( j, { "room": tempRoom })
        }
    }


    function newEvent ( type, chat_id, eventType, lastEvent ) {
        // Is the event necessary for the chat list? If not, then return
        if ( !(eventType === "timeline" || type === "m.typing" || type === "m.room.name" || type === "m.room.avatar" || type === "m.receipt") ) return

        // Search the room in the model
        var j = 0
        for ( j = 0; j < model.count; j++ ) {
            if ( model.get(j).room.id === chat_id ) break
        }
        if ( j === model.count ) return
        var tempRoom = model.get(j).room

        if ( eventType === "timeline" ) {
            // Update the last message preview
            var body = lastEvent.content.body || ""
            if ( type !== "m.room.message" ) {
                body = displayEvents.getDisplay ( lastEvent )
            }
            tempRoom.eventsid = lastEvent.event_id
            tempRoom.origin_server_ts = lastEvent.origin_server_ts
            tempRoom.content_body = body
            tempRoom.sender = lastEvent.sender
            tempRoom.content_json = JSON.stringify( lastEvent.content )
            tempRoom.type = lastEvent.type
        }
        if ( type === "m.typing" ) {
            // Update the typing list
            tempRoom.typing = lastEvent
        }
        else if ( type === "m.room.name" ) {
            // Update the room name
            tempRoom.topic = lastEvent.content.name
        }
        else if ( type === "m.room.avatar" ) {
            // Update the room avatar
            tempRoom.avatar_url = lastEvent.content.url
        }
        else if ( type === "m.receipt" && lastEvent.user === settings.matrixid ) {
            // Update the room avatar
            tempRoom.unread = lastEvent.ts
        }
        else if ( type === "m.room.member" && (tempRoom.topic === "" || tempRoom.topic === null || tempRoom.avatar_url === "" || tempRoom.avatar_url === null) ) {
            // Update the room name or room avatar calculation
            model.remove ( j )
            model.insert ( j, { "room": tempRoom })
        }
        model.set ( j, { "room": tempRoom })

        // Now reorder this item
        var here = j
        while ( j > 0 && tempRoom.origin_server_ts > model.get(j-1).room.origin_server_ts ) j--
        if ( here !== j ) model.move( here, j, 1 )
    }


    Connections {
        target: events
        onNewChatUpdate: newChatUpdate ( chat_id, membership, notification_count, highlight_count, limitedTimeline )
        onNewEvent: newEvent ( type, chat_id, eventType, eventContent )
    }

    header: StyledPageHeader {
        id: header
        title: shareObject === null ? i18n.tr("FluffyChat") : i18n.tr("Share")
        flickable: chatListView

        leadingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "close"
                visible: shareObject !== null
                onTriggered: shareObject = null
            }]
        }

        contents: Rectangle {
            anchors.fill: parent
            color: theme.palette.normal.background
            Label {
                id: headerTitle
                anchors.top: parent.top
                anchors.margins: units.gu(1.5)
                text: header.title
                textSize: Label.Large
                color: settings.mainColor
            }
            Button {
                id: addChatButton
                visible: shareObject === null
                color: settings.mainColor
                text: i18n.tr("Add chat")
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.leftMargin: units.gu(2)
                anchors.topMargin: units.gu(1)
                onClicked: newChatMode = !newChatMode
            }

            ActionBar {
                anchors.top: parent.top
                anchors.right: addChatButton.left
                anchors.rightMargin: units.gu(1)
                height: header.height / 2
                StyleHints {
                    iconColor: settings.mainColor
                }
                actions: [
                Action {
                    iconName: "filters"
                    text: i18n.tr("Settings")
                    visible: shareObject === null
                    onTriggered: {
                        searchField.text = ""
                        mainStack.toStart ("./pages/SettingsPage.qml")
                    }
                }
                ]
            }
        }

        extension: Rectangle {
            width: parent.width
            height: searchField.height + units.gu(1)
            color: theme.palette.normal.background
            anchors.bottom: parent.bottom

            TextField {
                id: searchField
                objectName: "searchField"
                z: 5
                property var searchMatrixId: false
                property var upperCaseText: displayText.toUpperCase()
                property var tempElement: null
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
                placeholderText: i18n.tr("Search for your chats...")
            }
        }
    }


    LeaveChatDialog { id: leaveChatDialog }




    ListModel { id: model }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        delegate: ChatListItem {}
        model: model
        move: Transition {
            SmoothedAnimation { property: "y"; duration: 300 }
        }
        displaced: Transition {
            SmoothedAnimation { property: "y"; duration: 300 }
        }

        Label {
            text: i18n.tr("Press the button at the top right to start a new chat or discover public groups.")
            textSize: Label.Large
            color: UbuntuColors.graphite
            anchors.centerIn: parent
            width: parent.width - units.gu(4)
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            wrapMode: Text.Wrap
            visible: model.count === 0
        }
    }

    property var newChatMode: false

    Rectangle {
        id: newChatRect
        anchors.fill: parent
        color: settings.darkmode ? "#DD000000" : "#DDFFFFFF"
        opacity: 0
        visible: opacity !== 0
        z: 10

        Button {
            id: closeNewChatButton
            color: settings.mainColor
            text: i18n.tr("Close")
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: units.gu(2)
            anchors.topMargin: units.gu(1)
            onClicked: newChatMode = !newChatMode
            width: addChatButton.width
        }

        transitions: Transition {
            NumberAnimation { property: "opacity"; duration: 350}
        }
        states: State {
            name: "visible"; when: newChatMode
            PropertyChanges {
                target: newChatRect
                opacity: 1
            }
        }

        MouseArea {
            onClicked: newChatMode = false
            anchors.fill: parent
            enabled: parent.visible
        }

        FlyingButton {
            id: createChatButton
            iconName: "contact"
            transitions: Transition {
                to: "visible"
                SpringAnimation {
                    spring: 2.5
                    damping: 0.2
                    properties: "anchors.rightMargin, opacity"
                }
            }
            states: State {
                name: "visible"; when: newChatRect.opacity !== 0
                PropertyChanges {
                    target: createChatButton
                    anchors.rightMargin: createChatButton.height / 2
                }
            }
            mouseArea.onClicked: {
                newChatMode = false
                mainStack.toStart ("./pages/CreateChatPage.qml")
            }
            anchors.top: parent.top
            anchors.topMargin: addChatButton.height*2
            anchors.bottom: undefined
            anchors.rightMargin: -width
        }

        Label {
            text: i18n.tr("New private chat")
            anchors.right: createChatButton.left
            anchors.verticalCenter: createChatButton.verticalCenter
            anchors.margins: units.gu(2)
            textSize: Label.Large
            color: mainFontColor
        }

        FlyingButton {
            id: createGroupButton
            iconName: "contact-group"
            transitions: Transition {
                to: "visible"
                SpringAnimation {
                    spring: 2
                    damping: 0.2
                    properties: "anchors.rightMargin, opacity"
                }
            }
            states: State {
                name: "visible"; when: newChatRect.opacity !== 0
                PropertyChanges {
                    target: createGroupButton
                    anchors.rightMargin: createGroupButton.height / 2
                }
            }
            mouseArea.onClicked: {
                newChatMode = false
                matrix.post( "/client/r0/createRoom", {
                    preset: "private_chat"
                }, function ( response ) {
                    toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
                    mainStack.toChat ( response.room_id )
                    mainStack.push(Qt.resolvedUrl("./InvitePage.qml"))
                }, null, 2 )
            }
            anchors.top: createChatButton.bottom
            anchors.bottom: undefined
            anchors.rightMargin: -width
        }

        Label {
            text: i18n.tr("New group")
            anchors.right: createGroupButton.left
            anchors.verticalCenter: createGroupButton.verticalCenter
            anchors.margins: units.gu(2)
            textSize: Label.Large
            color: mainFontColor
        }

        FlyingButton {
            id: joinChatButton
            iconName: "find"
            transitions: Transition {
                to: "visible"
                SpringAnimation {
                    spring: 1.5
                    damping: 0.2
                    properties: "anchors.rightMargin, opacity"
                }
            }
            states: State {
                name: "visible"; when: newChatRect.opacity !== 0
                PropertyChanges {
                    target: joinChatButton
                    anchors.rightMargin: createChatButton.height / 2
                }
            }
            mouseArea.onClicked: {
                newChatMode = false
                mainStack.toStart ("./pages/DiscoverPage.qml")
            }
            anchors.top: createGroupButton.bottom
            anchors.bottom: undefined
            anchors.rightMargin: -width
        }

        Label {
            text: i18n.tr("Public groups")
            anchors.right: joinChatButton.left
            anchors.verticalCenter: joinChatButton.verticalCenter
            anchors.margins: units.gu(2)
            textSize: Label.Large
            color: mainFontColor
        }
    }

}
