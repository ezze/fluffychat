import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0

Item {

    // This function helps to send a message. It automatically repeats, if there
    // was an error with the connection.
    function sendMessage ( messageID, data, chat_id, success_callback, error_callback ) {
        var newMessageID = ""
        var callback = function () { if ( newMessageID !== "" ) success_callback ( newMessageID ) }
        if ( !Connectivity.online ) {
            storage.transaction ( "UPDATE Events SET status=-1 WHERE id='" + messageID + "'" )
            return error_callback ( "ERROR" )
        }

        var msgtype = data.msgtype === "m.text" ? "m.room.message" : data.msgtype
        matrix.put( "/client/r0/rooms/" + chat_id + "/send/" + msgtype + "/" + messageID, data, function ( response ) {
            console.log("MESSAGE SENT :)))")
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
                if ( error_callback ) error_callback ("DELETE")
            }
            else if ( error.errcode === "M_UNKNOWN" ) {
                toast.show ( error.error )
                storage.transaction ( "DELETE FROM Events WHERE id='" + messageID + "'", callback )
                if ( error_callback ) error_callback ("DELETE")
            }
            // Else: Try again in a few seconds
            else {
                console.log("ERRORMSG")
                storage.transaction ( "UPDATE Events SET status=-1 WHERE id='" + messageID + "'" )
                if ( error_callback ) error_callback ("ERROR")
            }

        } )
    }

}
