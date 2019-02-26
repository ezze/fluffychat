import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Qt.labs.settings 1.0
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/MessageFormats.js" as MessageFormats

/*============================= STORAGE MODEL =============================

The storage model is responsible for the database. There are some helper
functions for transactions and for the config table. In the future, the
database model will change sometimes and apps with a previous version must
drop their existing database and replace with it with the new model. In this
case, the storage controller will detect this via the version-property. If there
are changes to the database model, the version-property MUST be increaded!
*/

Item {

    id: storage

    property var version: "0.3.5"
    property string lastVersion: ""
    property var db: LocalStorage.openDatabaseSync("FluffyChat", "2.0", "FluffyChat Database", 1000000)

    Settings {
        property alias lastVersion: storage.lastVersion
    }

    // Shortener for the sqlite transactions
    function query ( query, insert ) {
        try {
            var rs = {}
            db.transaction(
                function(tx) {
                    if ( insert ) rs = tx.executeSql( query, insert )
                    else rs = tx.executeSql( query )
                }
            )
            return rs
        }
        catch (e) {
            console.error("❌[Error]",e,query)
            if ( e.code && e.code === 2 ) {
                lockedScreen.visible = true
            }
        }
    }


    // Initializing the database
    Component.onCompleted: {
        // Check the database version number
        if ( lastVersion !== version ) {
            console.log ("👷[Init] Create the database and drop previous one if existing")
            matrix.prevBatch = ""
            drop ()
            lastVersion = version
        }
        query ( 'PRAGMA foreign_keys = OFF')
        query ( 'PRAGMA locking_mode = EXCLUSIVE')
        query ( 'PRAGMA temp_store = MEMORY')
        query ( 'PRAGMA cache_size')
        query ( 'PRAGMA cache_size = 10000')

        // TABLE SCHEMA FOR CHATS
        query('CREATE TABLE IF NOT EXISTS Chats(' +
        'id TEXT PRIMARY KEY, ' +
        'membership TEXT, ' +
        'topic TEXT, ' +
        'highlight_count INTEGER, ' +
        'notification_count INTEGER, ' +
        'limitedTimeline INTEGER, ' +
        'prev_batch TEXT, ' +
        'avatar_url TEXT, ' +
        'draft TEXT, ' +
        'unread INTEGER, ' +        // Timestamp of when the user has last read the chat
        'fully_read TEXT, ' +       // ID of the fully read marker event
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
        query('CREATE TABLE IF NOT EXISTS Events(' +
        'id TEXT PRIMARY KEY, ' +
        'chat_id TEXT, ' +
        'origin_server_ts INTEGER, ' +
        'sender TEXT, ' +
        'state_key TEXT, ' +
        'content_body TEXT, ' +
        'content_msgtype STRING, ' +
        'type TEXT, ' +
        'content_json TEXT, ' +
        "status INTEGER, " +
        'UNIQUE(id))')

        // TABLE SCHEMA FOR USERS
        query('CREATE TABLE IF NOT EXISTS Users(' +
        'matrix_id TEXT, ' +
        'displayname TEXT, ' +
        'avatar_url TEXT, ' +
        'presence TEXT, ' +
        'currently_active INTEGER, ' +
        'last_active_ago INTEGER, ' +
        'UNIQUE(matrix_id))')

        // TABLE SCHEMA FOR MEMBERSHIPS
        query('CREATE TABLE IF NOT EXISTS Memberships(' +
        'chat_id TEXT, ' +      // The chat id of this membership
        'matrix_id TEXT, ' +    // The matrix id of this user
        'displayname TEXT, ' +
        'avatar_url TEXT, ' +
        'membership TEXT, ' +   // The status of the membership. Must be one of [join, invite, ban, leave]
        'power_level INTEGER, ' +   // The power level of this user. Must be in [0,..,100]
        'UNIQUE(chat_id, matrix_id))')

        // TABLE SCHEMA FOR CONTACTS
        query('CREATE TABLE IF NOT EXISTS Contacts(' +
        'medium TEXT, ' +       // The medium this contact is identified by
        'address TEXT, ' +      // The email or phone number of this user if exists
        'matrix_id TEXT, ' +    // The matrix id of this user
        'UNIQUE(matrix_id))')

        // TABLE SCHEMA FOR CHAT ADDRESSES
        query('CREATE TABLE IF NOT EXISTS Addresses(' +
        'chat_id TEXT, ' +    // The correct chat id in the form: !hashstring:homeserver.org
        'address TEXT, ' + // The address in the form: #roomname:homeserver.org
        'UNIQUE(chat_id, address))')

        // TABLE SCHEMA FOR THIRD PARTY IDENTIFIES
        query('CREATE TABLE IF NOT EXISTS ThirdPIDs(' +
        'medium TEXT, ' +    // Should be "email" or "msisdn"
        'address TEXT, ' + // The email address or phone number
        'UNIQUE(medium, address))')

        // TABLE SCHEMA FOR UPLOADED MEDIA
        query('CREATE TABLE IF NOT EXISTS Media(' +
        'mimetype TEXT, ' +
        'url TEXT, ' +
        'name TEXT, ' +
        'thumbnail_url TEXT, ' +
        'UNIQUE(url))')

        if ( matrix.isLogged ) {
            storage.markSendingEventsAsError ()
        }
    }

    Connections {
        target: matrix
        onIsLoggedChanged: {
            if ( matrix.isLogged ) {
                storage.markSendingEventsAsError ()
            }
            else storage.clear ()
        }
    }


    function clear () {
        query('DELETE FROM Chats')
        query('DELETE FROM Events')
        query('DELETE FROM Users')
        query('DELETE FROM Memberships')
        query('DELETE FROM Contacts')
        query('DELETE FROM Addresses')
        query('DELETE FROM ThirdPIDs')
        query('DELETE FROM Media')
    }


    function drop () {
        query('DROP TABLE IF EXISTS Chats')
        query('DROP TABLE IF EXISTS Events')
        query('DROP TABLE IF EXISTS Users')
        query('DROP TABLE IF EXISTS Memberships')
        query('DROP TABLE IF EXISTS Contacts')
        query('DROP TABLE IF EXISTS Addresses')
        query('DROP TABLE IF EXISTS ThirdPIDs')
        query('DROP TABLE IF EXISTS Media')
    }


    // Save all incomming events in the database
    Connections {
        target: matrix

        onNewChatUpdate: {
            // Insert the chat into the database if not exists
            var insertResult = storage.query ("INSERT OR IGNORE INTO Chats " +
            "VALUES('" + chat_id + "', '" + membership + "', '', 0, 0, 0, '', '', '', 0, '', '', '', '', '', '', 0, 50, 50, 0, 50, 50, 0, 50, 100, 50, 50, 50, 100) ")

            // Update the notification counts and the limited timeline boolean
            var updateResult = storage.query ( "UPDATE Chats SET " +
            " highlight_count=" + highlight_count +
            ", notification_count=" + notification_count +
            ", membership='" + membership +
            "', limitedTimeline=" + limitedTimeline +
            " WHERE id='" + chat_id + "' AND ( " +
            " highlight_count!=" + highlight_count +
            " OR notification_count!=" + notification_count +
            " OR membership!='" + membership +
            "' OR limitedTimeline!=" + limitedTimeline +
            ") ")
            // Is the timeline limited? Then all previous messages should be
            // removed from the database!
            if ( limitedTimeline ) {
                storage.query ("DELETE FROM Events WHERE chat_id='" + chat_id + "'")
                storage.query ("UPDATE Chats SET prev_batch='" + prevBatch + "' WHERE id='" + chat_id + "'")
            }
        }

        onNewEvent: {
            // Save timeline events in the database
            if ( eventType === "timeline" || eventType === "history" ) {
                var status = msg_status.RECEIVED
                if ( eventContent.status ) status = eventContent.status
                else if ( eventType === "history" ) status = msg_status.HISTORY

                // Format the text for the app
                if( eventContent.content.body ) eventContent.content_body = MessageFormats.formatText ( eventContent.content.body )
                else eventContent.content_body = null

                // Make unsigned part of the content
                if ( eventContent.content.unsigned === undefined && eventContent.unsigned !== undefined ) {
                    eventContent.content.unsigned = eventContent.unsigned
                }

                storage.query ( "INSERT OR REPLACE INTO Events VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [ eventContent.event_id,
                chat_id,
                eventContent.origin_server_ts,
                eventContent.sender,
                eventContent.state_key || eventContent.sender,
                eventContent.content_body,
                eventContent.content.msgtype || null,
                eventContent.type,
                JSON.stringify(eventContent.content),
                status ])
            }

            if ( eventType === "history" ) return

            // Handle state events
            switch ( type ) {

            case "m.presence":
                var query = "UPDATE Users SET presence = '%1' ".arg( eventContent.content.presence )
                if ( eventContent.content.currently_active !== undefined ) query += ", currently_active = %1 ".arg( eventContent.content.currently_active ? "1" : "0" )
                if ( eventContent.content.last_active_ago !== undefined ) query += ", last_active_ago = %1 ".arg( (new Date().getTime() - eventContent.content.last_active_ago).toString() )
                query += "WHERE matrix_id = '%1'".arg(eventContent.sender)
                storage.query( query )
                break

            case "m.receipt":
                if ( eventContent.user === matrix.matrixid ) {
                    storage.query( "UPDATE Chats SET unread=? WHERE id=?",
                    [ eventContent.ts || new Date().getTime(),
                    chat_id ])
                }
                else {
                    // Mark all previous received messages as seen
                    storage.query ( "UPDATE Events SET status=3 WHERE origin_server_ts<=" + eventContent.ts +
                    " AND chat_id='" + chat_id + "' AND status=2")
                }
                break
                // This event means, that the name of a room has been changed, so
                // it has to be changed in the database.
            case "m.room.name":
                storage.query( "UPDATE Chats SET topic=? WHERE id=?",
                [ eventContent.content.name,
                chat_id ])
                break
                // This event means, that the topic of a room has been changed, so
                // it has to be changed in the database
            case "m.room.topic":
                storage.query( "UPDATE Chats SET description=? WHERE id=?",
                [ MessageFormats.formatText(eventContent.content.topic) || "",
                chat_id ])
                break
                // This event means, that the canonical alias of a room has been changed, so
                // it has to be changed in the database
            case "m.room.canonical_alias":
                storage.query( "UPDATE Chats SET canonical_alias=? WHERE id=?",
                [ eventContent.content.alias || "",
                chat_id ])
                break
                // This event means, that the topic of a room has been changed, so
                // it has to be changed in the database
            case "m.room.history_visibility":
                storage.query( "UPDATE Chats SET history_visibility=? WHERE id=?",
                [ eventContent.content.history_visibility,
                chat_id ])
                break
                // This event means, that the topic of a room has been changed, so
                // it has to be changed in the database
            case "m.room.redaction":
                storage.query( "DELETE FROM Events WHERE id=?",
                [ eventContent.redacts ])
                break
                // This event means, that the topic of a room has been changed, so
                // it has to be changed in the database
            case "m.room.guest_access":
                storage.query( "UPDATE Chats SET guest_access=? WHERE id=?",
                [ eventContent.content.guest_access,
                chat_id ])
                break
                // This event means, that the topic of a room has been changed, so
                // it has to be changed in the database
            case "m.room.join_rules":
                storage.query( "UPDATE Chats SET join_rules=? WHERE id=?",
                [ eventContent.content.join_rule,
                chat_id ])
                break
                // This event means, that the avatar of a room has been changed, so
                // it has to be changed in the database
            case "m.room.avatar":
                storage.query( "UPDATE Chats SET avatar_url=? WHERE id=?",
                [ eventContent.content.url,
                chat_id ])
                break
                // This event means, that the aliases of a room has been changed, so
                // it has to be changed in the database
            case "m.room.aliases":
                storage.query( "DELETE FROM Addresses WHERE chat_id='" + chat_id + "'")
                for ( var alias = 0; alias < eventContent.content.aliases.length; alias++ ) {
                    storage.query( "INSERT INTO Addresses VALUES(?,?)",
                    [ chat_id, eventContent.content.aliases[alias] ] )
                }
                break
                // This event means, that the aliases of a room has been changed, so
                // it has to be changed in the database
            case "m.fully_read":
                storage.query( "UPDATE Chats SET fully_read=? WHERE id=?",
                [ eventContent.content.event_id,
                chat_id ])
                // This event means, that someone joined the room, has left the room
                // or has changed his nickname
            case "m.room.member":
                // Update user database
                if ( eventContent.content.membership !== "leave" && eventContent.content.membership !== "ban" ) storage.query( "INSERT OR REPLACE INTO Users VALUES(?, ?, ?, 'offline', 0, 0)",
                [ eventContent.state_key,
                eventContent.content.displayname || MatrixNames.transformFromId(eventContent.state_key),
                eventContent.content.avatar_url || "" ])

                var memberInsertResult = storage.query( "INSERT OR IGNORE INTO Memberships VALUES('" + chat_id + "', '" + eventContent.state_key + "', ?, ?, ?, " +
                "COALESCE(" +
                "(SELECT power_level FROM Memberships WHERE chat_id='" + chat_id + "' AND matrix_id='" + eventContent.state_key + "'), " +
                "(SELECT power_user_default FROM Chats WHERE id='" + chat_id + "')" +
                "))",
                [ eventContent.content.displayname || "",
                eventContent.content.avatar_url || "",
                eventContent.content.membership ])

                if ( memberInsertResult.rowsAffected === 0 ) {
                    var queryStr = "UPDATE Memberships SET membership='" + eventContent.content.membership + "'"
                    if ( eventContent.content.displayname !== undefined ) queryStr += ", displayname='" + (eventContent.content.displayname || "") + "' "
                    if ( eventContent.content.avatar_url !== undefined ) queryStr += ", avatar_url='" + (eventContent.content.avatar_url || "") + "' "
                    queryStr += " WHERE matrix_id='" + eventContent.state_key + "' AND chat_id='" + chat_id + "'"
                    storage.query( queryStr )
                }
                break
                // This event changes the permissions of the users and the power levels
            case "m.room.power_levels":
                var query = "UPDATE Chats SET "
                if ( eventContent.content.ban ) query += ", power_ban=" + eventContent.content.ban
                if ( eventContent.content.events_default ) query += ", power_events_default=" + eventContent.content.events_default
                if ( eventContent.content.state_default ) query += ", power_state_default=" + eventContent.content.state_default
                if ( eventContent.content.redact ) query += ", power_redact=" + eventContent.content.redact
                if ( eventContent.content.invite ) query += ", power_invite=" + eventContent.content.invite
                if ( eventContent.content.kick ) query += ", power_kick=" + eventContent.content.kick
                if ( eventContent.content.user_default ) query += ", power_user_default=" + eventContent.content.user_default
                if ( eventContent.content.events ) {
                    if ( eventContent.content.events["m.room.avatar"] ) query += ", power_event_avatar=" + eventContent.content.events["m.room.avatar"]
                    if ( eventContent.content.events["m.room.history_visibility"] ) query += ", power_event_history_visibility=" + eventContent.content.events["m.room.history_visibility"]
                    if ( eventContent.content.events["m.room.canonical_alias"] ) query += ", power_event_canonical_alias=" + eventContent.content.events["m.room.canonical_alias"]
                    if ( eventContent.content.events["m.room.aliases"] ) query += ", power_event_aliases=" + eventContent.content.events["m.room.aliases"]
                    if ( eventContent.content.events["m.room.name"] ) query += ", power_event_name=" + eventContent.content.events["m.room.name"]
                    if ( eventContent.content.events["m.room.power_levels"] ) query += ", power_event_power_levels=" + eventContent.content.events["m.room.power_levels"]
                }
                if ( query !== "UPDATE Chats SET ") {
                    query = query.replace(",","")
                    storage.query( query + " WHERE id=?",[ chat_id ])
                }

                // Set the users power levels:
                if ( eventContent.content.users ) {
                    for ( var user in eventContent.content.users ) {
                        var updateResult = storage.query( "UPDATE Memberships SET power_level=? WHERE matrix_id=? AND chat_id=?",
                        [ eventContent.content.users[user],
                        user,
                        chat_id ])
                        if ( updateResult.rowsAffected === 0 ) {
                            storage.query( "INSERT OR IGNORE INTO Memberships VALUES(?, ?, '', '', ?, ?)",
                            [ chat_id,
                            user,
                            "unknown",
                            eventContent.content.users[user] ])
                        }
                    }
                }
                break
            }
        }
    }

    function markSendingEventsAsError () {
        storage.query ( "UPDATE Events SET status=-1 WHERE status=0" )
    }

}
