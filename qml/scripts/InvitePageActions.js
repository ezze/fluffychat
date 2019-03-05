// File: InvitePageActions.js
// Description: Actions for InvitePage.qml

function init () {
    var res = storage.query ( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Contacts.medium, Contacts.address FROM Users LEFT JOIN Contacts " +
    " ON Contacts.matrix_id=Users.matrix_id ORDER BY Contacts.medium DESC LIMIT 1000" )
    for( var i = 0; i < res.rows.length; i++ ) {
        var user = res.rows[i]
        if ( activeChatMembers[user.matrix_id] !== undefined ) continue
        model.append({
            matrix_id: user.matrix_id,
            name: user.displayname || MatrixNames.transformFromId(user.matrix_id),
            avatar_url: user.avatar_url,
            medium: user.medium || "matrix",
            address: user.address || user.matrix_id,
            temp: false
        })
    }
}


function search () {
    var displayText = searchField.displayText
    searchField.searchMatrixId = displayText.slice( 0,1 ) === "@"

    if ( searchField.searchMatrixId && displayText.indexOf(":") !== -1 ) {
        if ( searchField.tempElement !== null ) {
            model.remove ( searchField.tempElement)
            searchField.tempElement = null
        }
        model.append ( {
            matrix_id: displayText,
            name: MatrixNames.transformFromId(displayText),
            medium: "matrix",
            address: displayText,
            avatar_url: "",
            temp: true
        })
        searchField.tempElement = model.count - 1
    }
}
