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

        var msgtype = data.msgtype === "m.sticker" ? data.msgtype : "m.room.message"
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
                storage.transaction ( "UPDATE Events SET status=-1 WHERE id='" + messageID + "'" )
                if ( error_callback ) error_callback ("ERROR")
            }

        } )
    }

    function handleCommands ( data ) {
        // Transform the message body with the "/"-commands:
        if ( data.body.slice(0,1) === "/" ) {
            // Implement the /me feature
            if ( data.body.slice(0,4) === "/me " ) {
                data.body = data.body.replace("/me ", "" )
                data.msgtype = "m.emote"
            }
            else if ( data.body.slice(0,9) === "/whisper " ) {
                data.body = data.body.replace("/whisper ","")
                data.msgtype = "m.fluffychat.whisper"
            }
            else if ( data.body.slice(0,6) === "/roar " ) {
                data.body = data.body.replace("/roar ","")
                data.msgtype = "m.fluffychat.roar"
            }
            else if ( data.body.slice(0,7) === "/shrug" ) {
                data.body = data.body.replace("/shrug","¯_(ツ)_/¯")
            }
            else if ( data.body.slice(0,7) === "/reply:" ) {
                var words = data.body.split(" ")
                var replyId = words[0].replace("/reply:","")
                delete words[0]
                data.body = words.join(" ")
                data.formatted_body = '<mx-reply><blockquote><a href="https://matrix.to/#/%1/%2">' +
                'In reply to</a> <a href="https://matrix.to/#/%3">%4</a><br>%5</blockquote></mx-reply>'
                .arg(activeChat).arg(replyId).arg(replySender).arg(replySender).arg(data.body)
                data["m.relates_to"] = {
                    "m.in_reply_to": {
                        "event_id": replyId
                    }
                }
                data.formattedBody
            }
        }
        return data
    }

}
