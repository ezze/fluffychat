// File: js
// Description: Provides some help functions to get displaynames or show user profiles

function getById ( matrixid, roomid, callback ) {
    var username = transformFromId( matrixid )
    var rs = storage.query ( "SELECT displayname FROM Users WHERE matrix_id=?", [ matrixid ] )
    if ( rs.rows.length > 0 && rs.rows[0].displayname !== null ) username = rs.rows[0].displayname
    if ( callback ) callback ( username )
    return username
}


// This returns the local part of a matrix id
function transformFromId ( matrixid ) {
    if ( typeof matrixid !== "string" ) return ""
    return capitalizeFirstLetter ( (matrixid.substr(1)).split(":")[0] )
}


function medium2Section ( medium ) {
    switch ( medium ) {
        case "msisdn": return i18n.tr("Phone contacts:")
        case "email": return i18n.tr("Email contacts:")
        case "matrix": return i18n.tr("Users from your chats:")
    }
}


// Just capitalize the first letter of a string
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}


function getTypingDisplayString ( user_ids, roomname ) {
    if ( user_ids.length === 0 ) return ""
    if ( user_ids.length === 1 ) {
        var username = getById( user_ids[0] )
        if ( username === roomname ) return i18n.tr("✏ is typing…")
        else return i18n.tr("✏ %1 is typing…").arg( username )
    }
    else if ( user_ids.length > 1 ) {
        return i18n.tr("✏ %1 and %2 more are typing…").arg( username ).arg( user_ids.length-1 )
    }
    else return ""
}

function powerlevelToStatus ( power_level ) {
    if ( power_level < 50 ) return i18n.tr('Members')
    else if ( power_level < 99 ) return i18n.tr('Moderators')
    else if ( power_level < 100 ) return i18n.tr('Admins')
    else return i18n.tr('Owners')
}


function showUserSettings ( matrix_id ) {
    activeUser = matrix_id
    bottomEdgePageStack.push ( Qt.resolvedUrl ("../pages/UserPage.qml"))
}


function showCommunity ( matrix_id ) {
    var item = Qt.createComponent("../components/CommunityViewer.qml")
    item.createObject( root, { activeCommunity: matrix_id})
}


function handleUserUri ( uri ) {
    if ( uri.slice(0,1) === "@" && uri.indexOf(":") !== -1 ) {
        showUserSettings ( uri )
    }
    else {
        toast.show(i18n.tr("%1 is not a valid username").arg(uri))
    }
}


function stringToColor ( str ) {
    if ( str.indexOf("@") !== -1 ) str = getChatAvatarById ( str )
    var number = 0
    for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
    number = (number % 10) / 10
    return Qt.hsla( number, 1, 0.7, 1 )
}


function stringToDarkColor ( str ) {
    if ( str === null ) return Qt.hsla( 0, 0.8, 0.35, 1 )
    if ( str.indexOf("@") !== -1 ) str = getChatAvatarById ( str )
    var number = 0
    for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
    number = (number % 10) / 10
    return Qt.hsla( number, 1, 0.35, 1 )
}


// This function detects the room name of a chatroom.
// Unfortunetly we need a callback function, because of the sql queries ...
function getChatAvatarById ( chat_id, callback ) {
    var displayname = i18n.tr('Empty chat')
    var rs = storage.query ( "SELECT topic FROM Chats WHERE id=?", [ chat_id ] )
    if ( rs.rows.length > 0 && rs.rows[0].topic !== null && rs.rows[0].topic !== "" ) {
        displayname = rs.rows[0].topic
        if ( callback )  callback ( displayname )
    }
    else {
        // If it is a one on one chat, then use the displayname of the buddy
        rs = storage.query( "SELECT Memberships.displayname, Memberships.matrix_id, Memberships.membership FROM Memberships " +
        " WHERE Memberships.chat_id=? " +
        " AND (Memberships.membership='join' OR Memberships.membership='invite') " +
        " AND Memberships.matrix_id!=? ",
        [ chat_id, matrix.matrixid ] )
        var displayname = i18n.tr('Empty chat')
        if ( rs.rows.length > 0 ) {
            displayname = ""
            for ( var i = 0; i < rs.rows.length; i++ ) {
                var username = rs.rows[i].displayname || transformFromId ( rs.rows[i].matrix_id )
                if ( rs.rows[i].state_key !== matrix.matrixid ) displayname += username + ", "
            }
            if ( displayname === "" || displayname === null ) displayname = i18n.tr('Empty chat')
            else displayname = displayname.substr(0, displayname.length-2)
        }
        if ( callback ) callback ( displayname )
        // Else, use the default: "Empty chat"
    }
    return displayname
}


function getAvatarUrl ( chat_id, callback ) {
    var rs = storage.query ( "SELECT avatar_url FROM Chats " +
    " WHERE id=? ", [ chat_id ] )
    if ( rs.rows.length > 0 && rs.rows[0].avatar_url !== "" && rs.rows[0].avatar_url !== null ) callback ( rs.rows[0].avatar_url )
    else getAvatarFromSingleChat ( chat_id, callback )
}


function getUserAvatarUrl ( matrix_id, callback ) {
    var avatar_url = ""
    var rs = storage.query ( "SELECT avatar_url FROM Users " +
    " WHERE matrix_id=? ", [ matrix_id ] )
    if ( rs.rows.length > 0 && rs.rows[0].avatar_url !== "" && rs.rows[0].avatar_url !== null ) avatar_url = rs.rows[0].avatar_url
    if ( callback ) callback ( avatar_url )
    return avatar_url
}


function getAvatarFromSingleChat ( chat_id, callback ) {
    var avatarStr = ""
    var rs = storage.query( "SELECT Users.avatar_url FROM Users, Memberships " +
    " WHERE Memberships.matrix_id=Users.matrix_id " +
    " AND Memberships.chat_id=? " +
    " AND (Memberships.membership='join' OR Memberships.membership='invite') " +
    " AND Memberships.matrix_id!=? ",
    [ chat_id, matrix.matrixid ] )
    if ( rs.rows.length === 1 ) avatarStr = rs.rows[0].avatar_url
    if ( callback ) callback ( "" )
    return avatarStr
}


function getChatTime ( stamp ) {
    var date = new Date ( stamp )
    var now = new Date ()
    var locale = Qt.locale()
    var fullTimeString = date.toLocaleTimeString(locale, Locale.ShortFormat)


    if ( date.getDate()  === now.getDate()  &&
    date.getMonth() === now.getMonth() &&
    date.getFullYear() === now.getFullYear() ) {
        return fullTimeString
    }

    return date.toLocaleString(locale, Locale.ShortFormat)
}


function getThumbnailFromMxc ( mxc, width, height ) {
    if ( mxc === undefined || mxc === null ) return ""

    var mxcID = mxc.replace("mxc://","")
    //Qt.resolvedUrl()

    if ( !isDownloading ) {
        isDownloading = true
        //downloader.download ( getThumbnailLinkFromMxc ( mxc, width, height ) )
    }


    return getThumbnailLinkFromMxc ( mxc, width, height )
}


function getThumbnailLinkFromMxc ( mxc, width, height ) {
    width = Math.round(width)
    height = Math.round(height)
    if ( mxc === undefined || mxc === "" ) return ""
    if ( matrix.online ) {
        var server = matrix.server
        if (!server.match(/^https?:/)) {
            server = "https://" + server
        }
        return server + "/_matrix/media/r0/thumbnail/" + mxc.replace("mxc://","") + "?width=" + width * units.gu(1)  + "&height=" + height * units.gu(1)  + "&method=scale"
    }
    else {
        return downloadPath + mxc.split("/")[3]
    }

}


function getLinkFromMxc ( mxc ) {
    if ( mxc === undefined ) return ""
    var mxcID = mxc.replace("mxc://","")
    var server = matrix.server
    if (!server.match(/^https?:/)) {
        server = "https://" + server
    }
    return server + "/_matrix/media/r0/download/" + mxcID + "/"
}
