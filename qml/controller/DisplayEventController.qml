import QtQuick 2.4
import Ubuntu.Components 1.3

/*============================= STORAGE CONTROLLER =============================

This is a little helper controller to get a display text from a room event, which
is NOT a message. Currently, only invitations, create and member changes are displayed.
*/

Item {
    function getDisplay ( event ) {
        event.content = JSON.parse (event.content_json)
        var body = i18n.tr("Unknown Event: ") + event.type
        var sendername = (event.displayname || usernames.transformFromId(event.sender))
        var displayname = event.content.displayname || event.displayname || usernames.transformFromId(event.sender) || i18n.tr("Someone")
        var target = event.content.displayname || i18n.tr("Someone")
        if ( event.type === "m.room.member" ) {
            if ( event.content.membership === "join" ) {
                body = i18n.tr("%1 has joined the chat as <b>%2</b>").arg(event.sender).arg(displayname)
            }
            else if ( event.content.membership === "invite" ) {
                body = i18n.tr("%1 has invited %2").arg(sendername).arg( target )
                console.log(JSON.stringify(event))
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
            body = i18n.tr("%1 has changed the chat name").arg(displayname)
        }
        else if ( event.type === "m.room.topic" ) {
            body = i18n.tr("%1 has changed the chat topic").arg(displayname)
        }
        else if ( event.type === "m.room.avatar" ) {
            body = i18n.tr("%1 has changed the chat avatar").arg(displayname)
        }
        else if ( event.type === "m.sticker" ) {
            body = i18n.tr("%1 has sent a sticker").arg(displayname)
        }
        else if ( event.type === "m.room.history_visibility" ) {
            body = i18n.tr("%1 has set the chat history visible to: ").arg(displayname)
            if ( event.content.history_visibility === "shared" ) {
                body += i18n.tr("All chatters")
            }
            else if ( event.content.history_visibility === "joined" ) {
                body += i18n.tr("All joined chat participants")
            }
            else if ( event.content.history_visibility === "invited" ) {
                body += i18n.tr("All invited chat participants")
            }
            else if ( event.content.history_visibility === "world_readable" ) {
                body += i18n.tr("Everyone")
            }
        }
        else if ( event.type === "m.room.join_rules" ) {
            body = i18n.tr("%1 has set the join rules to: ").arg(displayname)
            if ( event.content.join_rule === "invite" ) {
                body += i18n.tr("Only invited users")
            }
            else if ( event.content.join_rule === "public" ) {
                body += i18n.tr("Public")
            }
            else if ( event.content.join_rule === "private" ) {
                body += i18n.tr("Private")
            }
            else if ( event.content.join_rule === "knock" ) {
                body += i18n.tr("Knock")
            }
        }
        else if ( event.type === "m.room.guest_access" ) {
            body = i18n.tr("%1 has set the guest access to: ").arg(displayname)
            if ( event.content.guest_access === "can_join" ) {
                body += i18n.tr("Can join")
            }
            else if ( event.content.guest_access === "forbidden" ) {
                body += i18n.tr("Forbidden")
            }
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
        body += "."
        return body
    }
}
