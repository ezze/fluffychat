// File: NotificationTargetSettingsPageActions.js
// Description: Actions for NotificationTargetSettingsPage.qml


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
                if ( response.global[type][i].rule_id === ".m.rule.master" ) {
                    mrule_master.isChecked = !response.global[type][i].enabled
                    break
                }
            }
        }

        notificationSettingsList.enabled = true

    } );
}

function getTargets () {
    matrix.get ( "/client/r0/pushers", null, function ( response ) {
        targetList.children = ""
        for ( var i = 0; i < response.pushers.length; i++ ) {
            var newListItem = Qt.createComponent("../components/TargetListItem.qml")
            newListItem.createObject(targetList, { target: response.pushers[i] } )
        }
    })
}
