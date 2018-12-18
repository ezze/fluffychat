import QtQuick 2.9
import Ubuntu.Components 1.3

/*============================= USERNAME CONTROLLER ============================
The username controller is just a little helper to get the user display name
from a userid address, such like: "#alice@matrix.org"
*/

Item {

    function getById ( matrixid, roomid, callback ) {
        var username = transformFromId( matrixid )
        storage.transaction ( "SELECT displayname FROM Users WHERE matrix_id='" + matrixid + "'", function(rs) {
            if ( rs.rows.length > 0 && rs.rows[0].displayname !== null ) username = rs.rows[0].displayname
            if ( callback ) callback ( username )
        })
        return username
    }


    // This returns the local part of a matrix id
    function transformFromId ( matrixid ) {
        if ( typeof matrixid !== "string" ) return ""
        return capitalizeFirstLetter ( (matrixid.substr(1)).split(":")[0] )
    }

    // Just capitalize the first letter of a string
    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    function getTypingDisplayString ( user_ids, roomname ) {
        if ( user_ids.length === 0 ) return ""
        var username = usernames.getById( user_ids[0] )
        if ( user_ids.length === 1 ) {
            if ( username === roomname ) return i18n.tr("⌨️ is typing…")
            else return i18n.tr("⌨️ %1 is typing…").arg( username )
        }
        else if ( user_ids.length > 1 ) {
            return i18n.tr("⌨️ %1 and %2 more are typing…").arg( username ).arg( user_ids.length-1 )
        }
        else return ""
    }

    function powerlevelToStatus ( power_level ) {
        if ( power_level < 50 ) return i18n.tr('Members')
        else if ( power_level < 100 ) return i18n.tr('Moderators')
        else return i18n.tr('Admins')
    }

    function showUserSettings ( matrix_id ) {
        activeUser = matrix_id
        var item = Qt.createComponent("../components/UserSettingsViewer.qml")
        item.createObject(mainStack.currentPage, { })
    }

    function handleUserUri ( uri ) {
        if ( uri.slice(0,1) === "@" && uri.indexOf(":") !== -1 ) {
            usernames.showUserSettings ( uri )
        }
        else {
            toast.show(i18n.tr("%1 is not a valid username").arg(uri))
        }
    }

    function stringToColor ( str ) {
        if ( str.indexOf("@") !== -1 ) str = usernames.getById ( str )
        var number = 0
        for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
        number = (number % 10) / 10
        return Qt.hsla( number, 0.6, 0.6, 1 )
    }

    function stringToDarkColor ( str ) {
        if ( str.indexOf("@") !== -1 ) str = usernames.getById ( str )
        var number = 0
        for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
        number = (number % 10) / 10
        return Qt.hsla( number, 0.8, 0.35, 1 )
    }
}
