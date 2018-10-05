import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0

Item {

    // This function helps to send a message. It automatically repeats, if there
    // was an error with the connection.
    function sendMessage ( messageID, data, chat_id, success_callback, error_callback ) {
        var newMessageID = ""
        var callback = function () { if ( newMessageID !== "" ) success_callback ( newMessageID ) }
        if ( !Connectivity.online ) return console.log ("Offline!!!!!1111")

        var msgtype = data.msgtype === "m.text" ? "m.room.message" : data.msgtype
        matrix.put( "/client/r0/rooms/" + chat_id + "/send/" + msgtype + "/" + messageID, data, function ( response ) {
            newMessageID = response.event_id
            storage.transaction ( "SELECT * FROM Events WHERE id='" + response.event_id + "'", function ( res ) {
                if ( res.rows.length > 0 ) {
                    storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                }
                else {
                    storage.transaction ( "UPDATE Events SET id='" + response.event_id + "', status=1 WHERE id='" + messageID + "'", callback )
                }

            })
        }, function ( error ) {
            console.warn("Sending message error: ", error.errcode, ": ", error.error)

            // If the user has no permissions or there is an internal server error,
            // the message gets deleted
            if ( error.errcode === "M_FORBIDDEN" ) {
                toast.show ( i18n.tr("You are not allowed to chat here.") )
                storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                if ( error_callback ) error_callback ()
            }
            else if ( error.errcode === "M_UNKNOWN" ) {
                toast.show ( error.error )
                storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                if ( error_callback ) error_callback ()
            }
            // Else: Try again in a few seconds
            else if ( Connectivity.online ) {
                function Timer() {
                    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
                }
                var timer = new Timer()
                timer.interval = miniTimeout
                timer.repeat = false
                timer.triggered.connect(function () {
                    var newMessageID = "%" + new Date().getTime();
                    storage.transaction ( "UPDATE Events SET id='" + newMessageID + "', status=1 WHERE id='" + messageID + "'", function () {
                        sendMessage ( newMessageID, data, chat_id, callback )
                    } )
                })
                timer.start();
            }

        } )
    }


    // If the user starts the app or is online again, all sending messages should
    // restart sending
    function resendAllMessages () {
        storage.transaction ( "SELECT id, chat_id, content_body FROM Events WHERE status=0", function ( rs) {
            if ( rs.rows.length === 0 ) return
            var event = rs.rows[0]
            var data = {
                msgtype: "m.text",
                body: event.content_body
            }
            sendMessage ( event.id, data, event.chat_id, function (){} )
            if ( rs.rows.length > 1 ) {
                function Timer() {
                    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
                }
                var timer = new Timer()
                timer.interval = miniTimeout
                timer.repeat = false
                timer.triggered.connect(sender.resendAllMessages)
                timer.start();
            }
        } )
    }
    

    Connections {
        target: Connectivity
        onOnlineChanged: if ( Connectivity.online ) sender.resendAllMessages ()
    }

}
