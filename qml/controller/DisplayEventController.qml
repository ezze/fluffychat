import QtQuick 2.4
import Ubuntu.Components 1.3

/*============================= STORAGE CONTROLLER =============================

This is a little helper controller to get a display text from a room event, which
is NOT a message. Currently, only invitations, create and member changes are displayed.
*/

Item {
    function getDisplay ( event ) {
        if ( !("content" in event) ) event.content = JSON.parse (event.content_json)
        var body = i18n.tr("Unknown Event: ") + event.type
        var sendername = (event.displayname || usernames.transformFromId(event.sender))
        var displayname = event.content.displayname || event.displayname || usernames.transformFromId(event.sender) || i18n.tr("Someone")
        var target = event.content.displayname || i18n.tr("Someone")
        if ( event.type === "m.room.member" ) {
            if ( event.content.membership === "join" ) {
                if ( usernames.transformFromId(event.sender) === displayname ) {
                    body = i18n.tr("%1 is now participating").arg(displayname)
                }
                else body = i18n.tr("%1 is now participating as <b>%2</b>").arg(event.sender).arg(displayname)
            }
            else if ( event.content.membership === "invite" ) {
                body = i18n.tr("%1 has invited %2").arg(sendername).arg( target )
            }
            else if ( event.content.membership === "leave" ) {
                body = i18n.tr("%1 has left the chat").arg(displayname)
            }
            else if ( event.content.membership === "ban" ) {
                body = i18n.tr("%1 has been banned from the chat").arg(displayname)
            }
        }
        else if ( event.type === "m.room.create" ) {
            body = i18n.tr("Chat created")
        }
        else if ( event.type === "m.room.name" ) {
            body = i18n.tr("%1 has changed the chat name to: <b>%2</b>").arg(displayname).arg(event.content.name)
        }
        else if ( event.type === "m.room.topic" ) {
            body = i18n.tr("%1 has changed the chat topic to: <b>%2</b>").arg(displayname).arg(event.content.topic)
        }
        else if ( event.type === "m.room.avatar" ) {
            body = i18n.tr("%1 has changed the chat avatar").arg(displayname)
        }
        else if ( event.type === "m.room.redaction" ) {
            body = i18n.tr("%1 has redacted a message").arg(displayname)
        }
        else if ( event.type === "m.sticker" ) {
            body = i18n.tr("%1 has sent a sticker").arg(displayname)
        }
        else if ( event.type === "m.room.history_visibility" ) {
            body = i18n.tr("%1 has set the chat history visible to: %2").arg(displayname).arg(translate ( event.content.history_visibility ))
        }
        else if ( event.type === "m.room.join_rules" ) {
            body = i18n.tr("%1 has set the join rules to: %2").arg(displayname).arg( translate ( event.content.join_rule ) )
        }
        else if ( event.type === "m.room.guest_access" ) {
            body = i18n.tr("%1 has set the guest access to: %2").arg(displayname).arg( translate ( event.content.guest_access ) )
        }
        else if ( event.type === "m.room.aliases" ) {
            body = i18n.tr("The chat aliases have been changed.")
            for ( var i = 0; i < event.content.aliases; i++ ) {
                body += event.content.aliases[i] + " "
            }
        }
        else if ( event.type === "m.room.canonical_alias" ) {
            body = i18n.tr("The canonical chat alias has been changed to: ") + event.content.alias
        }
        else if ( event.type === "m.room.power_levels" ) {
            body = i18n.tr("The chat permissions have been changed")
        }
        return body
    }

    function translate ( type ) {
        if ( type === "invite" ) {
            return i18n.tr("Only invited users")
        }
        else if ( type === "public" ) {
            return i18n.tr("Public")
        }
        else if ( type === "private" ) {
            return i18n.tr("Private")
        }
        else if ( type === "knock" ) {
            return i18n.tr("Knock")
        }
        else if ( type === "shared" ) {
            return i18n.tr("All chatters")
        }
        else if ( type === "joined" ) {
            return i18n.tr("All joined chat participants")
        }
        else if ( type === "invited" ) {
            return i18n.tr("All invited chat participants")
        }
        else if ( type === "world_readable" ) {
            return i18n.tr("Everyone")
        }
        else if ( type === "can_join" ) {
            return i18n.tr("Can join")
        }
        else if ( type === "forbidden" ) {
            return i18n.tr("Forbidden")
        }
    }
}
