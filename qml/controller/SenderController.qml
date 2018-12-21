import QtQuick 2.9
import Ubuntu.Components 1.3

Item {

    property var urlRegex: /((^| )(?:(?:https?|ftp|fluffychat|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$]))/igm
    property var aliasRegex: /((^| )#(\w+):(\w+)(\.(\w+))+)/gm
    property var usernameRegex: /((^| )@(\w+):(\w+)(\.(\w+))+)/gm
    property var roomIdRegex: /((^| )!(\w+):(\w+)(\.(\w+))+)/gm
    property var markdownLinkRegex: /\[([^\[\]]+)\]\(([^)]+\))/gm

    // This function helps to send a message. It automatically repeats, if there
    // was an error with the connection.
    function sendMessage ( messageID, data, chat_id, success_callback, error_callback ) {
        var newMessageID = ""
        var callback = function () { if ( newMessageID !== "" ) success_callback ( newMessageID ) }
        if ( !events.online ) {
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


    function formatText ( tempText ) {
        // HTML characters
        tempText = tempText.split("&").join("&amp;")
        .split("<").join("&lt;")
        .split(">").join("&gt;")
        .split('"').join("&quot;")

        // Format markdown links
        tempText = tempText.replace(markdownLinkRegex, function(str) {
            var name = str.split("[")[1].split("]")[0]
            var link = str.split("(")[1].split(")")[0]
            return '<a href="%1">%2</a>'.arg(link).arg(name)
        })

        // Detect common https urls and make them clickable
        tempText = tempText.replace(urlRegex, function(url) {
            if ( url.indexOf(" ") !== -1 ) {
                url = url.replace(" ","")
                return ' <a href="%1">%2</a>'.arg(url).arg(url)
            }
            else return '<a href="%1">%2</a>'.arg(url).arg(url)
        })

        // Make matrix identifier clickable
        var replaceMatrixUri = function(url) {
            if ( url.indexOf(" ") !== -1 ) {
                url = url.replace(" ","")
                return ' <a href="fluffychat://%1">%2</a>'.arg(url).arg(url)
            }
            else return '<a href="fluffychat://%1">%2</a>'.arg(url).arg(url)
        }
        tempText = tempText.replace(aliasRegex, replaceMatrixUri)
        tempText = tempText.replace(usernameRegex, replaceMatrixUri)
        tempText = tempText.replace(roomIdRegex, replaceMatrixUri)

        // Set the newline tags correct
        tempText = tempText.replace("\n","<br>")

        return formatReply ( tempText )
    }

    function formatReply ( tempText ) {
        if ( tempText.slice(0,9) === "&gt; &lt;" ) {
            var lines = tempText.split("\n")
            var user = lines[0].split("&lt;")[1].split("&gt;")[0]
            lines[0] = lines[0].replace( user, "<a href='fluffychat://%1'>%2</a>".arg(user).arg(user))
            lines[0] = lines[0].replace("&gt; ", "")
            lines[0] = lines[0].replace("&gt;",":")
            lines[0] = lines[0].replace("&lt;","<font color='" + settings.brightMainColor + "'>")
            lines[0] += "</font>"
            for ( var i = 1; i < lines.length; i++ ) {
                if ( lines[i].slice(0,4) === "&gt;" ) {
                    lines[i] = lines[i].replace("&gt;", "<font color='#888888'>")
                    lines[i] += "</font>"
                }
                else break
            }
            tempText = lines.join(" <br>")
        }
        return tempText
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
            else if ( data.body.slice(0,6) === "/shrug" ) {
                data.body = data.body.replace("/shrug","¯\_(ツ)_/¯")
            }
        }
        return data
    }

}
