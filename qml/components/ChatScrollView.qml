import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListView {

    id: chatScrollView

    // If this property is not 1, then the user is not in the chat, but is reading the history
    property var historyCount: 30
    property var requesting: false
    property var initialized: -1
    property var count: model.count
    property var unread: ""
    property var canRedact: false
    property var chatMembers: []

    function init () {
        // Request all participants displaynames and avatars
        storage.transaction ( "SELECT user.matrix_id, user.displayname, user.avatar_url, membership.membership " +
        " FROM Memberships membership, Users user " +
        " WHERE membership.chat_id='" + activeChat +
        "' AND membership.matrix_id=user.matrix_id "
        , function (memberResults) {
            // Make sure that the event for the users matrix id exists
            chatMembers[settings.matrixid] = {
                displayname: usernames.transformFromId(settings.matrixid),
                avatar_url: ""
            }
            for ( var i = 0; i < memberResults.rows.length; i++ ) {
                chatMembers[ memberResults.rows[i].matrix_id ] = memberResults.rows[i]
            }

            update ()
        })
    }

    function update ( sync ) {
        storage.transaction ( "SELECT id, type, content_json, content_body, origin_server_ts, sender, state_key, status " +
        " FROM Events " +
        " WHERE chat_id='" + activeChat +
        "' ORDER BY origin_server_ts DESC"
        , function (res) {
            // We now write the rooms in the column
            pushclient.clearPersistent ( activeChatDisplayName )

            model.clear ()
            initialized = res.rows.length
            for ( var i = res.rows.length-1; i >= 0; i-- ) {
                var event = res.rows.item(i)
                event.content = JSON.parse( event.content_json )
                addEventToList ( event, false )
                if ( event.matrix_id === null ) requestRoomMember ( event.sender )
            }

            // Scroll to last read event
            if ( unread !== "" ) {
                for ( var j = 0; j < count; j++ ) {
                    if ( model.get ( j ).event.id === unread ) {
                        currentIndex = j
                        break
                    }
                }
            }
        })
    }


    function requestHistory () {
        if ( initialized !== model.count || requesting || (model.count > 0 && model.get( model.count -1 ).event.type === "m.room.create") ) return
        toast.show ( i18n.tr( "Get more messages from the server ...") )
        requesting = true
        var storageController = storage
        storage.transaction ( "SELECT prev_batch FROM Chats WHERE id='" + activeChat + "'", function (rs) {
            if ( rs.rows.length === 0 ) return
            var data = {
                from: rs.rows[0].prev_batch,
                dir: "b",
                limit: historyCount
            }
            matrix.get( "/client/r0/rooms/" + activeChat + "/messages", data, function ( result ) {
                if ( result.chunk.length > 0 ) {
                    for ( var i = 0; i < result.chunk.length; i++ ) addEventToList ( result.chunk[i], true )
                    storageController.db.transaction(
                        function(tx) {
                            events.transaction = tx
                            events.handleRoomEvents ( activeChat, result.chunk, "history" )
                            requesting = false
                        }
                    )
                    storageController.transaction ( "UPDATE Chats SET prev_batch='" + result.end + "' WHERE id='" + activeChat + "'", function () {
                    })
                }
                else requesting = false
            }, function () { requesting = false } )
        } )
    }


    // This function writes the event in the chat. The event MUST have the format
    // of a database entry, described in the storage controller
    function addEventToList ( event, history ) {

        // Display this event at all? In the chat settings the user can choose
        // which events should be displayed. Less important events are all events,
        // that or not member events from other users and the room create events.
        if ( (!settings.showMemberChangeEvents && event.type === "m.room.member") ||
        (settings.hideLessImportantEvents &&
            event.type !== "m.room.message" &&
            event.type !== "m.sticker" &&
            event.type !== "m.room.member" &&
            event.type !== "m.room.create")
        ) return

        // Is the sender of this event in the local database? If not, then request
        // the displayname and avatar url of this sender.
        if ( chatMembers[event.sender] === undefined) {
            chatMembers[event.sender] = {
                "displayname": usernames.transformFromId ( event.sender ),
                "avatar_url": ""
            }
            matrix.get ( "/client/r0/rooms/%1/state/m.room.member/%2".arg(activeChat).arg(event.sender), {}, function ( response ) {
                var newEvent = {
                    content: response,
                    state_key: event.sender,
                    type: "m.room.member"
                }
                storage.db.transaction(
                    function(tx) {
                        events.transaction = tx
                        events.handleRoomEvents ( activeChat, [ newEvent ], "state" )
                    }
                )
            })
        }


        if ( !("content_body" in event) ) event.content_body = event.content.body
        event.sameSender = false
        if ( history ) event.status = msg_status.HISTORY


        // If there is a transaction id, remove the sending event and end here
        if ( "unsigned" in event && "transaction_id" in event.unsigned ) {
            event.unsigned.transaction_id = event.unsigned.transaction_id
            for ( var i = 0; i < model.count; i++ ) {
                var tempEvent = model.get(i).event
                if ( tempEvent.id === event.unsigned.transaction_id || tempEvent.id === event.id) {
                    if ( i > 0 ) event.sameSender = tempEvent.sameSender
                    console.log("Dublication Transaction!", i, event.sameSender)
                    model.set( i, { "event": event } )
                    return
                }
            }
        }


        // Find the right position for this event
        var j = history ? model.count : 0
        if ( !history ) {
            while ( j < model.count && event.origin_server_ts < model.get(j).event.origin_server_ts ) j++
        }

        // If the previous message has the same sender and is a normal message
        // then it is not necessary to show the user avatar again
        if ( j < model.count ) {
            var tempEvent = model.get(j).event
            if ( tempEvent.sender === event.sender && (event.type === "m.room.message" || event.type === "m.sticker") ) {
                tempEvent.sameSender = true
                model.set ( j, { "event": tempEvent })
            }
        }
        if ( j > 0 ) {
            var tempEvent = model.get(j-1).event
            event.sameSender = tempEvent.sender === event.sender && (tempEvent.type === "m.room.message" || tempEvent.type === "m.sticker")
        }
        else event.sameSender = false


        // Check that there is no duplication:
        if ( model.count > j && event.id === model.get(j).event.id ) {
            if ( j > 0 ) event.sameSender = model.get(j).event.sameSender
            model.set( j, { "event": event } )
            return
        }


        // Now insert it
        model.insert ( j, { "event": event } )
        initialized = model.count
    }


    function messageSent ( oldID, newID ) {
        // TODO: SameSender always true
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).event.id === oldID ) {
                var tempEvent = model.get(i).event
                tempEvent.id = newID
                tempEvent.status = msg_status.SENT
                tempEvent.origin_server_ts = new Date().getTime()
                tempEvent.sameSender = false
                model.set( i, { "event": tempEvent } )

                // Move the event to the correct position if necessary
                var j = i
                while ( j > 0 && tempEvent.origin_server_ts > model.get(j).event.origin_server_ts ) j--
                if ( i !== j ) {
                    model.move( i, j, 1 )
                    if ( i > 0 ) {
                        var tempEvent = model.get(i).event
                        var nextEvent = model.get(i-1).event
                        tempEvent.sameSender = tempEvent.sender === nextEvent.sender && (nextEvent.type === "m.room.message" || nextEvent.type === "m.sticker")
                        model.set ( i, { "event": tempEvent })
                    }
                    if ( j > 0 ) {
                        var tempEvent = model.get(j).event
                        var nextEvent = model.get(j-1).event
                        tempEvent.sameSender = tempEvent.sender === nextEvent.sender && (nextEvent.type === "m.room.message" || nextEvent.type === "m.sticker")
                        model.set ( j, { "event": tempEvent })
                    }
                }
                break
            }
            else if ( model.get(i).event.id === newID ) break
        }
    }


    function errorEvent ( messageID ) {
        console.log("ERRORMSG", messageID)
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).event.id === messageID ) {
                console.log(i,msg_status.ERROR)
                var tempEvent = model.get(i).event
                tempEvent.status = msg_status.ERROR
                model.set( i, { "event": tempEvent } )
                break
            }
        }
    }


    // This function handles new events, based on the signal from the event
    // controller. It just has to format the event to the database format
    function handleNewEvent ( type, eventContent ) {
        eventContent.id = eventContent.event_id
        eventContent.status = msg_status.RECEIVED
        addEventToList ( eventContent )

        if ( type === "m.room.redaction" ) removeEvent ( eventContent.redacts )
    }


    function removeEvent ( event_id ) {
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).event.id === event_id ) {
                model.remove ( i )
                if ( i < model.count && i > 0 ) {
                    var tempEvent = model.get(i).event
                    var nextEvent = model.get(i-1).event
                    tempEvent.sameSender = tempEvent.sender === nextEvent.sender && (nextEvent.type === "m.room.message" || nextEvent.type === "m.sticker")
                    model.set ( i, { "event": tempEvent })
                }
                else if ( i === 0 ) {
                    var tempEvent = model.get(i).event
                    tempEvent.sameSender = true
                    model.set ( i, { "event": tempEvent })
                }
                break
            }
        }
    }


    function markRead ( timestamp ) {
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).event.sender === settings.matrixid &&
            model.get(i).event.origin_server_ts <= timestamp &&
            model.get(i).event.status > msg_status.SENT ) {
                var tempEvent = model.get(i).event
                tempEvent.status = msg_status.SEEN
                model.set( i, { "event": tempEvent } )
            }
            else if ( model.get(i).event.status === msg_status.SEEN ) break
        }
    }

    width: parent.width
    height: parent.height - 2 * chatInput.height
    anchors.bottom: chatInput.top
    verticalLayoutDirection: ListView.BottomToTop
    delegate: ChatEvent {}
    model: ListModel { id: model }
    onContentYChanged: if ( atYBeginning ) requestHistory ()
    move: Transition {
        NumberAnimation { property: "opacity"; to:1; duration: 1 }
    }
    displaced: Transition {
        SmoothedAnimation { property: "y"; duration: 300 }
        NumberAnimation { property: "opacity"; to:1; duration: 1 }
    }
    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to:1; duration: 200 }
    }
    remove: Transition {
        NumberAnimation { property: "opacity"; from: 1; to:0; duration: 200 }
    }
}
