import QtQuick 2.9
import Ubuntu.Components 1.3

/*============================= STORAGE CONTROLLER =============================

This is a little helper controller to get a display text from a room event, which
is NOT a message. Currently, only invitations, create and member changes are displayed.
*/

Item {
    function getDisplay ( event ) {
        if ( !("content" in event) ) event.content = JSON.parse (event.content_json)
        if ( event.content === null ) return i18n.tr("Unknown event")
        var body = i18n.tr("Unknown Event: ") + event.type
        var sendername = usernames.transformFromId(event.sender)
        var displayname = event.content.displayname || usernames.transformFromId(event.state_key)
        var unsigned = event.content.unsigned || false

        if ( event.type === "m.room.member" || event.type === "m.room.multipleMember" ) {
            if ( event.content.membership === "join" ) {
                if ( unsigned && unsigned.prev_content && unsigned.prev_content.membership === "join" ) {
                    if ( unsigned.prev_content.avatar_url !== event.content.avatar_url ) {
                        body = i18n.tr("%1 changed the avatar").arg(displayname)
                    }
                    else if ( unsigned.prev_content.displayname !== event.content.displayname ) {
                        body = i18n.tr("%1 changed the displayname to %2").arg(usernames.transformFromId(event.state_key)).arg(displayname)
                    }
                }
                else if ( unsigned && unsigned.prev_content && unsigned.prev_content.membership === "invite" ) {
                    body = i18n.tr("%1 accepted the invitation").arg(displayname)
                }
                else if ( usernames.transformFromId(event.state_key).toUpperCase() === displayname.toUpperCase() ) {
                    body = i18n.tr("%1 is now participating").arg(displayname)
                }
                else body = i18n.tr("%1 is now participating as <b>%2</b>").arg(sendername).arg(displayname)
            }
            else if ( event.content.membership === "invite" ) {
                body = i18n.tr("%1 invited %2").arg(sendername).arg( displayname )
            }
            else if ( event.content.membership === "leave" ) {
                if ( unsigned && unsigned.prev_content && unsigned.prev_content.membership === "ban" ) {
                    body = i18n.tr("%1 pardoned %2").arg(sendername).arg(displayname)
                }
                else if ( unsigned && unsigned.prev_content && unsigned.prev_content.membership === "invite" && event.sender === event.state_key ) {
                    body = i18n.tr("%1 declined the invitation").arg(displayname)
                }
                else if ( event.sender === event.state_key ) {
                    body = i18n.tr("%1 left the chat").arg(displayname)
                }
                else body = i18n.tr("%1 kicked %2").arg( sendername ).arg( displayname )
            }
            else if ( event.content.membership === "ban" ) {
                body = i18n.tr("%1 banned %2 from the chat").arg(sendername).arg(displayname)
            }
            if ( event.type === "m.room.multipleMember" ) {
                body += " " + i18n.tr("and more member changes")
            }
        }
        else if ( event.type === "m.room.create" ) {
            body = i18n.tr("%1 created the chat").arg(sendername)
        }
        else if ( event.type === "m.room.name" ) {
            body = i18n.tr("%1 changed the chat name to: «%2»").arg(sendername).arg(event.content.name)
        }
        else if ( event.type === "m.room.topic" ) {
            body = i18n.tr("%1 changed the chat topic to: «%2»").arg(sendername).arg(event.content.topic)
        }
        else if ( event.type === "m.room.avatar" ) {
            body = i18n.tr("%1 changed the chat avatar").arg(sendername)
        }
        else if ( event.type === "m.room.redaction" ) {
            body = i18n.tr("%1 redacted a message").arg(sendername)
        }
        else if ( event.type === "m.room.encryption" ) {
            body = i18n.tr("%1 initialized end to end encryption. Be aware that FluffyChat does not yet support end to end encryption. You will not be able to send or read messages in this chat!").arg(displayname)
        }
        else if ( event.type === "m.room.encrypted" ) {
            body = i18n.tr("Encrypted message")
        }
        else if ( event.type === "m.sticker" ) {
            body = i18n.tr("%1 sent a sticker").arg(sendername)
        }
        else if ( event.type === "m.room.history_visibility" ) {
            body = i18n.tr("%1 set the chat history visible to: «%2»").arg(sendername).arg(translate ( event.content.history_visibility ))
        }
        else if ( event.type === "m.room.join_rules" ) {
            body = i18n.tr("%1 set the join rules to: «%2»").arg(sendername).arg( translate ( event.content.join_rule ) )
        }
        else if ( event.type === "m.room.guest_access" ) {
            body = i18n.tr("%1 set the guest access to: «%2»").arg(sendername).arg( translate ( event.content.guest_access ) )
        }
        else if ( event.type === "m.room.aliases" ) {
            body = i18n.tr("%1 changed the chat aliases").arg(sendername)
            for ( var i = 0; i < event.content.aliases; i++ ) {
                body += event.content.aliases[i] + " "
            }
        }
        else if ( event.type === "m.room.canonical_alias" ) {
            body = i18n.tr("%1 changed the canonical chat alias to: «%2»").arg(sendername).arg(event.content.alias)
        }
        else if ( event.type === "m.room.power_levels" ) {
            body = i18n.tr("%1 changed the chat permissions").arg(sendername)
        }
        else if ( event.type === "m.fluffy.me" ) {
            body = event.content_body
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
