import QtQuick 2.4
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
        storage.transaction ( "SELECT user.matrix_id, user.displayname, user.avatar_url " +
        " FROM Memberships membership, Users user " +
        " WHERE membership.chat_id='" + activeChat +
        "' AND membership.matrix_id=user.matrix_id "
        , function (memberResults) {
            for ( var i = 0; i < memberResults.rows.length; i++ ) {
                chatMembers[ memberResults.rows[i].matrix_id ] = memberResults.rows[i]
            }
            update ()
        })
    }

    function update ( sync ) {
        storage.transaction ( "SELECT id, type, content_json, content_body, origin_server_ts, sender, status " +
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
                    for ( var i = result.chunk.length-1; i >= 0; i-- ) addEventToList ( result.chunk[i], true )
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

        // Find the right position for this event
        var j = history ? model.count-1 : 0
        if ( history ) {
            while ( j > 0 && event.origin_server_ts > model.get(j).event.origin_server_ts ) j--
        }
        else {
            while ( j < model.count-1 && event.origin_server_ts < model.get(j+1).event.origin_server_ts ) j++
        }

        // Check that there is no duplication:
        if ( model.count > j && event.id === model.get(j).event.id ) model.remove ( j )

        // If the previous message has the same sender and is a normal message
        // then it is not necessary to show the user avatar again
        if ( history ) {
            if ( model.count > 0 && model.get(j-1).event.sender === event.sender ) {
                var i = j-1
                var tempEvent = model.get(i).event
                tempEvent.sameSender = true
                model.remove ( i )
                model.insert ( i, { "event": tempEvent } )
            }
        }
        else {
            event.sameSender = model.count > j && model.count > 0 &&
            model.get(j).event.type === "m.room.message" &&
            model.get(j).event.sender === event.sender
        }


        // Now reorder this item and insert it
        model.insert ( j, { "event": event } )
        initialized = model.count
    }


    function messageSent ( oldID, newID ) {
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).event.id === oldID ) {
                var tempEvent = model.get(i).event
                tempEvent.id = newID
                tempEvent.status = msg_status.SENT
                model.remove ( i )
                model.insert ( i, { "event": tempEvent } )
                if ( model.count > i && newID === model.get(i+1).event.id ) model.remove ( i+1 )
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

        if ( type === "m.room.redaction" ) {
            for ( var i = 0; i < model.count; i++ ) {
                if ( model.get(i).event.id === eventContent.redacts ) {
                    model.remove ( i )
                    break
                }
            }
        }
    }


    function markRead ( timestamp ) {
        for ( var i = 0; i < model.count; i++ ) {
            if ( model.get(i).event.sender === matrix.matrixid &&
            model.get(i).event.origin_server_ts <= timestamp &&
            model.get(i).event.status > msg_status.SENT ) {
                var tempEvent = model.get(i).event
                tempEvent.status = msg_status.SEEN
                model.remove ( i )
                model.insert ( i, { "event": tempEvent } )
            }
            else if ( model.get(i).event.status === msg_status.SEEN ) break
        }
    }


    ActionSelectionPopover {
        id: contextualActions
        property var contextEvent
        z: 10
        actions: ActionList {
            Action {
                text: i18n.tr("Copy text")
                onTriggered: {
                    mimeData.text = contextualActions.contextEvent.content.body
                    Clipboard.push( mimeData )
                    toast.show( i18n.tr("Text has been copied to the clipboard") )
                }
            }
            Action {
                text: i18n.tr("Redact message")
                visible: canRedact
                onTriggered: {
                    showConfirmDialog ( i18n.tr("Are you sure?"), function () {
                        matrix.put( "/client/r0/rooms/%1/redact/%2/%3"
                        .arg(activeChat)
                        .arg(contextualActions.contextEvent.id)
                        .arg(new Date().getTime()) )
                    })
                }
            }
        }
    }

    MimeData {
        id: mimeData
        text: ""
    }

    width: parent.width
    height: parent.height - 2 * chatInput.height
    anchors.bottom: chatInput.top
    verticalLayoutDirection: ListView.BottomToTop
    delegate: ChatEvent {}
    model: ListModel { id: model }
    onContentYChanged: if ( atYBeginning ) requestHistory ()
}
