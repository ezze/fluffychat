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

    property var version: "0.3.1"
    property var db: LocalStorage.openDatabaseSync("FluffyChat", "2.0", "FluffyChat Database", 1000000)


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
        catch (e) {
            if ( e.code && e.code === 2 ) {
                console.log("Database locked!")
                lockedScreen.visible = true
            }
            else console.warn(e,transaction)
        }
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
        catch (e) {
            if ( e.code && e.code === 2 ) {
                console.log("Database locked!")
                toast.show ( i18n.tr("Please restart your device to complete the update!" ) )
            }
            else console.warn(e,transaction)
        }
    }


    // Initializing the database
    function init () {
        // Check the database version number
        if ( settings.dbversion !== version ) {
            console.log ("Drop database cause old version")
            settings.since = settings.requestedArchive = undefined
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
        transaction('DROP TABLE IF EXISTS Chats')
        transaction('DROP TABLE IF EXISTS Events')
        transaction('DROP TABLE IF EXISTS Users')
        transaction('DROP TABLE IF EXISTS Memberships')
        transaction('DROP TABLE IF EXISTS Contacts')
        transaction('DROP TABLE IF EXISTS Addresses')
        transaction('DROP TABLE IF EXISTS ThirdPIDs')

        // TABLE SCHEMA FOR CHATS
        transaction('CREATE TABLE Chats(' +
        'id TEXT PRIMARY KEY, ' +
        'membership TEXT, ' +
        'topic TEXT, ' +
        'highlight_count INTEGER, ' +
        'notification_count INTEGER, ' +
        'limitedTimeline INTEGER, ' +
        'prev_batch TEXT, ' +
        'avatar_url TEXT, ' +
        'draft TEXT, ' +
        'unread TEXT, ' +        // The event id of the last seen event
        'description TEXT, ' +
        'canonical_alias TEXT, ' +  // The address in the form: #roomname:homeserver.org

        // Security rules
        'guest_access TEXT, ' +
        'history_visibility TEXT, ' +
        'join_rules TEXT, ' +

        // Power levels
        'power_events_default INTEGER, ' +
        'power_state_default INTEGER, ' +
        'power_redact INTEGER, ' +
        'power_invite INTEGER, ' +
        'power_ban INTEGER, ' +
        'power_kick INTEGER, ' +
        'power_user_default INTEGER, ' +

        // Power levels for events
        'power_event_avatar INTEGER, ' +
        'power_event_history_visibility INTEGER, ' +
        'power_event_canonical_alias INTEGER, ' +
        'power_event_aliases INTEGER, ' +
        'power_event_name INTEGER, ' +
        'power_event_power_levels INTEGER, ' +

        'UNIQUE(id))')

        // TABLE SCHEMA FOR EVENTS
        transaction('CREATE TABLE Events(' +
        'id TEXT PRIMARY KEY, ' +
        'chat_id TEXT, ' +
        'origin_server_ts INTEGER, ' +
        'sender TEXT, ' +
        'content_body TEXT, ' +
        'content_msgtype STRING, ' +
        'type TEXT, ' +
        'content_json TEXT, ' +
        "status INTEGER, " +
        'UNIQUE(id))')

        // TABLE SCHEMA FOR USERS
        transaction('CREATE TABLE Users(' +
        'matrix_id TEXT, ' +
        'displayname TEXT, ' +
        'avatar_url TEXT, ' +
        'UNIQUE(matrix_id))')

        // TABLE SCHEMA FOR MEMBERSHIPS
        transaction('CREATE TABLE Memberships(' +
        'chat_id TEXT, ' +      // The chat id of this membership
        'matrix_id TEXT, ' +    // The matrix id of this user
        'membership TEXT, ' +   // The status of the membership. Must be one of [join, invite, ban, leave]
        'power_level INTEGER, ' +   // The power level of this user. Must be in [0,..,100]
        'UNIQUE(chat_id, matrix_id))')

        // TABLE SCHEMA FOR CONTACTS
        transaction('CREATE TABLE Contacts(' +
        'medium TEXT, ' +       // The medium this contact is identified by
        'address TEXT, ' +      // The email or phone number of this user if exists
        'matrix_id TEXT, ' +    // The matrix id of this user
        'UNIQUE(matrix_id))')

        // TABLE SCHEMA FOR CHAT ADDRESSES
        transaction('CREATE TABLE Addresses(' +
        'chat_id TEXT, ' +    // The correct chat id in the form: !hashstring:homeserver.org
        'address TEXT, ' + // The address in the form: #roomname:homeserver.org
        'UNIQUE(chat_id, address))')

        // TABLE SCHEMA FOR CHAT ADDRESSES
        transaction('CREATE TABLE ThirdPIDs(' +
        'medium TEXT, ' +    // Should be "email" or "msisdn"
        'address TEXT, ' + // The email address or phone number
        'UNIQUE(medium, address))')
    }
}
