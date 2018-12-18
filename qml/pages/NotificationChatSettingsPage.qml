import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    property var status: 0


    function setPushRule ( action ) {
        matrix.put ( "/client/r0/pushrules/global/room/%1".arg(activeChat), {"actions": [ action ] }, update )
    }

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

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
        } )
    }

    header: FcPageHeader {
        title: i18n.tr('Notifications')
    }

    Component.onCompleted: updateView ()

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth
            SettingsListItem {
                name: i18n.tr("Notify")
                Icon {
                    id: "notify"
                    visible: status === 3
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-high"
                onClicked: {
                    if ( status === 0 ) return
                    else if ( status === 1 ) matrix.remove ( "/client/r0/pushrules/global/override/%1".arg(activeChat), null, updateView )
                    else if ( status === 2 ) matrix.remove ( "/client/r0/pushrules/global/room/%1".arg(activeChat), null, updateView )
                }
            }
            SettingsListItem {
                name: i18n.tr("Only if mentioned")
                Icon {
                    id: "mentioned"
                    visible: status === 2
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-low"
                onClicked: {
                    if ( status === 0 ) return
                    else if ( status === 1 ) {
                        matrix.remove ( "/client/r0/pushrules/global/override/%1".arg(activeChat), null, function () {
                            matrix.put ( "/client/r0/pushrules/global/room/%1".arg(activeChat), {"actions": [ "dont_notify" ] }, updateView )
                        } )
                    }
                    else if ( status === 3 ) matrix.put ( "/client/r0/pushrules/global/room/%1".arg(activeChat), {"actions": [ "dont_notify" ] }, updateView )
                }
            }
            SettingsListItem {
                name: i18n.tr("Don't notify")
                Icon {
                    id: "dont_notify"
                    visible: status === 1
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-muted"
                onClicked: {
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
            }

        }
    }
}
