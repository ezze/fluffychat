// File: DiscoverPageActions.js
// Description: Actions for DiscoverPage.qml


// Add public rooms from a server side search to the model.
function addPublicRoomsToModel ( res ) {
    for( var i = 0; i < res.chunk.length; i++ ) {
        model.append ( { "room": res.chunk[i] } )
    }
}


function handleError ( error ) {
    loading = false
    label.text = error.error
}


function init () {
    // Set the limit
    var limit = 400
    // Search for public rooms on the homeserver
    matrix.get ( "/client/r0/publicRooms", { "limit": limit }, function ( res ) {
        addPublicRoomsToModel ( res )
        // Also search on matrix.org if not already
        if ( matrix.server !== "matrix.org" ) {
            matrix.get ( "/client/r0/publicRooms", { "limit": limit, "server": "matrix.org" }, function ( res ) {
                addPublicRoomsToModel ( res )
                loading = false
            }, handleError, 1 )
        }
        else loading = false
    }, handleError, 1 )

}


function displayTextChanged ( displayText ) {
    if ( searchField.tempElement ) {
        model.remove ( model.count - 1 )
        searchField.tempElement  = false
    }

    if ( displayText.slice( 0,1 ) === "#" ) {
        searchField.searchMatrixId = displayText
        if ( searchField.searchMatrixId.indexOf(":") === -1 ) searchField.searchMatrixId += ":%1".arg(matrix.server)


        model.append ( { "room": {
            room_id: searchField.searchMatrixId
        } } )
        searchField.tempElement = true
    }
}
