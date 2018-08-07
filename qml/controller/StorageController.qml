import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

/*============================= STORAGE CONTROLLER =============================

The storage controller is responsible for the database. There are some helper
functions for transactions and for the config table. In the future, the
database model will change sometimes and apps with a previous version must
drop their existing database and replace with it with the new model. In this
case, the storage controller will detect this via the version-property. If there
are changes to the database model, the version-property MUST be increaded!
*/

Item {
    id: storage

    property var version: "0.1.12"
    property var db: LocalStorage.openDatabaseSync("FLuffyChat", "1.0", "FluffyChat Database", 1000000)


    // Shortener for the sqlite transactions
    function transaction ( transaction, callback ) {
        try {
            db.transaction(
                function(tx) {
                    var rs = tx.executeSql( transaction )
                    if ( callback ) callback ( rs )
                }
            )
        }
        catch (e) { console.warn(e,transaction)}
    }


    function query ( query, insert, callback ) {
        try {
            db.transaction(
                function(tx) {
                    var rs = tx.executeSql( query, insert )
                    if ( callback ) callback ( rs )
                }
            )
        }
        catch (e) { console.warn(e,transaction)}
    }


    // Initializing the database
    function init () {
        // Check the database version number
        if ( settings.dbversion !== version ) {
            console.log ("Drop database cause old version")
            settings.since = undefined
            // Drop all databases and recreate them
            drop ()
            settings.dbversion = version
        }
        transaction ( 'PRAGMA foreign_keys = OFF')
        transaction ( 'PRAGMA locking_mode = EXCLUSIVE')
        transaction ( 'PRAGMA temp_store = MEMORY')
        transaction ( 'PRAGMA cache_size')
        transaction ( 'PRAGMA cache_size = 10000')
    }


    function drop () {
        transaction('DROP TABLE IF EXISTS Rooms')
        transaction('DROP TABLE IF EXISTS Roomevents')
        transaction('DROP TABLE IF EXISTS Roommembers')
        transaction('CREATE TABLE Rooms(id TEXT PRIMARY KEY, membership TEXT, topic TEXT, highlight_count INTEGER, notification_count INTEGER, limitedTimeline INTEGER, prev_batch TEXT, UNIQUE(id))')
        transaction('CREATE TABLE Roomevents(id TEXT PRIMARY KEY, roomsid TEXT, origin_server_ts INTEGER, sender TEXT, content_body TEXT, content_msgtype STRING, type TEXT, content_json TEXT, UNIQUE(id))')
        transaction('CREATE TABLE Roommembers(roomsid TEXT, state_key TEXT, membership TEXT, displayname TEXT, avatar_url TEXT, UNIQUE(roomsid, state_key))')
    }
}
