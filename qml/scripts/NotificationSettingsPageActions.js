// File: NotificationSettingsPageActions.js
// Description: Actions for NotificationSettingsPage.qml

function changeRule ( rule_id, enabled, type ) {
    console.log( notificationSettingsList.enabled )
    if ( notificationSettingsList.enabled ) {
        notificationSettingsList.enabled = false
        matrix.put ( "/client/r0/pushrules/global/%1/%2/enabled".arg(type).arg(rule_id), {"enabled": enabled}, getRules )
    }
}

function getRules () {
    matrix.get( "/client/r0/pushrules/", null, function ( response ) {

        notificationSettingsList.enabled = false

        for ( var type in response.global ) {
            for ( var i = 0; i < response.global[type].length; i++ ) {

                if ( response.global[type][i].rule_id === ".m.rule.suppress_notices" ) {
                    mrule_suppress_notices.isChecked = !response.global[type][i].enabled
                }
                else if ( response.global[type][i].rule_id === ".m.rule.invite_for_me" ) {
                    mrule_invite_for_me.isChecked = response.global[type][i].enabled
                }
                else if ( response.global[type][i].rule_id === ".m.rule.member_event" ) {
                    mrule_member_event.isChecked = response.global[type][i].enabled
                }
                else if ( response.global[type][i].rule_id === ".m.rule.contains_display_name" ) {
                    mrule_contains_display_name.isChecked = response.global[type][i].enabled
                }
                else if ( response.global[type][i].rule_id === ".m.rule.contains_user_name" ) {
                    mrule_contains_user_name.isChecked = response.global[type][i].enabled
                }
                else if ( response.global[type][i].rule_id === ".m.rule.room_one_to_one" ) {
                    mrule_room_one_to_one.isChecked = response.global[type][i].enabled
                }
                else if ( response.global[type][i].rule_id === ".m.rule.message" ) {
                    mrule_message.isChecked = response.global[type][i].enabled
                }


            }
        }

        notificationSettingsList.enabled = true

    } );
}
