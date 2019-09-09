// File: MessageFormats.js
// Description: Some helper functions to format messages

var urlRegex = /((^| )(?:(?:https?|ftp|fluffychat|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$]))/igm;
var aliasRegex = /((^| )#(\w+):(\w+)(\.(\w+))+)/gm;
var usernameRegex = /((^| )@(\w+):(\w+)(\.(\w+))+)/gm;
var roomIdRegex = /((^| )!(\w+):(\w+)(\.(\w+))+)/gm;
var communityIdRegex = /((^| )\+(\w+):(\w+)(\.(\w+))+)/gm;
var markdownLinkRegex = /\[([^\[\]]+)\]\(([^)]+\))/gm;
var linebreakRegex = /[\r\n]+/gm;
var emojiRegex = /^(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])+$/;

function formatText(tempText) {
    // HTML characters
    tempText = tempText.split("<").join("〈")
        .split(">").join("〉")

    // Format markdown links
    tempText = tempText.replace(markdownLinkRegex, function (str) {
        var name = str.split("[")[1].split("]")[0]
        var link = str.split("(")[1].split(")")[0]
        return '<a href="%1">%2</a>'.arg(link).arg(name)
    })

    // Detect common https urls and make them clickable
    tempText = tempText.replace(urlRegex, function (url) {
        if (url.slice(0, 1) === " ") {
            url = url.slice(1, url.length)
            return ' <a href="%1">%2</a>'.arg(url).arg(url)
        }
        return '<a href="%1">%2</a>'.arg(url).arg(url)
    })

    // Make matrix identifier clickable
    var replaceMatrixUri = function (url) {
        if (url.indexOf(" ") !== -1) {
            url = url.replace(" ", "")
            return ' <a href="fluffychat://%1">%2</a>'.arg(url).arg(url)
        }
        else return '<a href="fluffychat://%1">%2</a>'.arg(url).arg(url)
    }
    tempText = tempText.replace(aliasRegex, replaceMatrixUri)
    tempText = tempText.replace(usernameRegex, replaceMatrixUri)
    tempText = tempText.replace(roomIdRegex, replaceMatrixUri)
    tempText = tempText.replace(communityIdRegex, replaceMatrixUri)
    tempText = formatReply(tempText)

    // Set the newline tags correct
    tempText = tempText.replace(linebreakRegex, "<br>")

    tempText = tempText.split("&").join("&amp;")

    return tempText
}

function formatReply(tempText) {
    if (tempText.slice(0, 3) === "〉 〈") {
        var lines = tempText.split("\n")
        var user = lines[0].split("〈")[1].split("〉")[0]
        lines[0] = lines[0].replace(user, "<a href='fluffychat://%1'><font color='#888888'>%2:</font></a><br>".arg(user).arg(user))
        lines[0] = lines[0].replace("〉 ", "")
        lines[0] = lines[0].replace("〉", "<font color='#888888'>")
        lines[0] = lines[0].replace("〈", "")
        lines[0] += "</font>"
        for (var i = 1; i < lines.length; i++) {
            if (lines[i].slice(0, 1) === "〉") {
                lines[i] = lines[i].replace("〉", "<font color='#888888'>")
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


function handleCommands(data) {
    // Transform the message body with the "/"-commands:
    if (data.body.slice(0, 1) === "/") {
        // Implement the /me feature
        if (data.body.slice(0, 4) === "/me ") {
            data.body = data.body.replace("/me ", "")
            data.msgtype = "m.emote"
        }
        else if (data.body.slice(0, 9) === "/whisper ") {
            data.body = data.body.replace("/whisper ", "")
            data.msgtype = "m.fluffychat.whisper"
        }
        else if (data.body.slice(0, 6) === "/roar ") {
            data.body = data.body.replace("/roar ", "")
            data.msgtype = "m.fluffychat.roar"
        }
        else if (data.body.slice(0, 6) === "/shrug") {
            data.body = data.body.replace("/shrug", "¯\_(ツ)_/¯")
        }
    }
    return data
}
