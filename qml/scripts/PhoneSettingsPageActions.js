// File: PhoneSettingsPageActions.js
// Description: Actions for PhoneSettingsPage.qml


function sync () {
    update()

    // Check for updates online
    matrix.get( "/client/r0/account/3pid", null, function ( res ) {
        storage.query ( "DELETE FROM ThirdPIDs")
        if ( res.threepids.length === 0 ) return
        for ( var i = 0; i < res.threepids.length; i++ ) {
            storage.query ( "INSERT OR IGNORE INTO ThirdPIDs VALUES( ?, ? )", [ res.threepids[i].medium, res.threepids[i].address ])
        }
        update()
    })
}


function update () {
    // Get all phone numbers
    var response = storage.query ( "SELECT address FROM ThirdPIDs WHERE medium='msisdn'" )
    model.clear()
    for ( var i = 0; i < response.rows.length; i++ ) {
        model.append({
            name: response.rows[ i ].address
        })
    }
}
