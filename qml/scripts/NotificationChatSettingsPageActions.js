// File: NotificationChatSettingsPageActions.js
// Description: Actions for NotificationChatSettingsPage.qml

function updateView () {
    status = 0
    scrollView.opacity = 0.5
    matrix.get ( "/client/r0/pushrules/", null, function ( response ) {
        scrollView.opacity = 1

        // Case 1: Is the chatid a rule_id in the override rules and is there the action "dont_notify"?
        for ( var i = 0; i < response.global.override.length; i++ ) {
            if ( response.global.override[i].rule_id === activeChat ) {
                if ( response.global.override[i].actions.indexOf("dont_notify") !== -1 ) {
                    status = 1
                    return
                }
                break
            }
        }

        // Case 2: Is the chatid in the room rules and notifications are disabled?
        for ( var i = 0; i < response.global.room.length; i++ ) {
            if ( response.global.room[i].rule_id === activeChat ) {
                if ( response.global.room[i].actions.indexOf("dont_notify") !== -1 ) {
                    status = 2
                    return
                }
                break
            }
        }

        // Case 3: The notifications are enabled
        status = 3
    }, null, 1 )
}

function setNotify () {
    if ( status === 0 ) return
    else if ( status === 1 ) matrix.remove ( "/client/r0/pushrules/global/override/%1".arg(activeChat), null, updateView )
    else if ( status === 2 ) matrix.remove ( "/client/r0/pushrules/global/room/%1".arg(activeChat), null, updateView )
}

function setOnlyMentions () {
    if ( status === 0 ) return
    else if ( status === 1 ) {
        matrix.remove ( "/client/r0/pushrules/global/override/%1".arg(activeChat), null, function () {
            matrix.put ( "/client/r0/pushrules/global/room/%1".arg(activeChat), {"actions": [ "dont_notify" ] }, updateView )
        } )
    }
    else if ( status === 3 ) matrix.put ( "/client/r0/pushrules/global/room/%1".arg(activeChat), {"actions": [ "dont_notify" ] }, updateView )
}

function setMuted () {
    if ( status === 0 ) return
    else if ( status === 2 ) {
        matrix.remove ( "/client/r0/pushrules/global/room/%1".arg(activeChat), null, function () {
            matrix.put ( "/client/r0/pushrules/global/override/%1".arg(activeChat),
            {
                "actions": [ "dont_notify" ],
                "conditions": [{
                    "key": "room_id",
                    "kind": "event_match",
                    "pattern": activeChat
                }]
            }, updateView )
        } )

    }
    else if ( status === 3 ) {
        matrix.put ( "/client/r0/pushrules/global/override/%1".arg(activeChat),
        {
            "actions": [ "dont_notify" ],
            "conditions": [{
                "key": "room_id",
                "kind": "event_match",
                "pattern": activeChat
            }]
        }, updateView )
    }
}
