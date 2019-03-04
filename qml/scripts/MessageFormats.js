// File: MessageFormats.js
// Description: Some helper functions to format messages

var urlRegex = /((^| )(?:(?:https?|ftp|fluffychat|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$]))/igm;
var aliasRegex = /((^| )#(\w+):(\w+)(\.(\w+))+)/gm;
var usernameRegex = /((^| )@(\w+):(\w+)(\.(\w+))+)/gm;
var roomIdRegex = /((^| )!(\w+):(\w+)(\.(\w+))+)/gm;
var communityIdRegex = /((^| )\+(\w+):(\w+)(\.(\w+))+)/gm;
var markdownLinkRegex = /\[([^\[\]]+)\]\(([^)]+\))/gm;
var linebreakRegex = /[\r\n]+/gm

function formatText ( tempText ) {
    // HTML characters
    tempText = tempText.split("<").join("&lt;")
    .split(">").join("&gt;")

    // Format markdown links
    tempText = tempText.replace(markdownLinkRegex, function(str) {
        var name = str.split("[")[1].split("]")[0]
        var link = str.split("(")[1].split(")")[0]
        return '<a href="%1">%2</a>'.arg(link).arg(name)
    })

    // Detect common https urls and make them clickable
    tempText = tempText.replace(urlRegex, function(url) {
        if ( url.slice(0,1) === " " ) {
            url = url.slice(1, url.length)
            return ' <a href="%1">%2</a>'.arg(url).arg(url)
        }
        return '<a href="%1">%2</a>'.arg(url).arg(url)
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
    tempText = tempText.replace(communityIdRegex, replaceMatrixUri)
    tempText = formatReply ( tempText )

    // Set the newline tags correct
    tempText = tempText.replace(linebreakRegex,"<br>")

    tempText = tempText.split("&").join("&amp;")

    return tempText
}

function formatReply ( tempText ) {
    if ( tempText.slice(0,9) === "&gt; &lt;" ) {
        var lines = tempText.split("\n")
        var user = lines[0].split("&lt;")[1].split("&gt;")[0]
        lines[0] = lines[0].replace( user, "<a href='fluffychat://%1'><font color='#888888'>%2:</font></a><br>".arg(user).arg(user))
        lines[0] = lines[0].replace("&gt; ", "")
        lines[0] = lines[0].replace("&gt;","<font color='#888888'>")
        lines[0] = lines[0].replace("&lt;","")
        lines[0] += "</font>"
        for ( var i = 1; i < lines.length; i++ ) {
            if ( lines[i].slice(0,4) === "&gt;" ) {
                lines[i] = lines[i].replace("&gt;", "<font color='#888888'>")
                lines[i] += "</font>"
            }
            else {
                break
            }
        }
        tempText = lines.join("<br>")
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
