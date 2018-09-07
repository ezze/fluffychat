import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: usernames.getById ( activeUser ) + " (%1)".arg( status.substring(0, status.length - 1) )
        property var status: usernames.powerlevelToStatus(activeUserPower)
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        SettingsListItem {
            name: i18n.tr("Make a normal member")
            icon: "thumb-down"
            onClicked: {
                var data = {
                    users: {}
                }
                data.users[activeUser] = 0
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
                PopupUtils.close(dialogue)
            }
            visible: canChangePermissions && activeUserPower != 0 && activeUserMembership !== "ban"
        }
        SettingsListItem {
            name: i18n.tr("Make a guard")
            icon: activeUserPower < 50 ? "thumb-up" : "thumb-down"
            onClicked: {
                var data = {
                    users: {}
                }
                data.users[activeUser] = 50
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
                PopupUtils.close(dialogue)
            }
            visible: canChangePermissions && activeUserPower != 50 && activeUserMembership !== "ban"
        }
        SettingsListItem {
            name: i18n.tr("Make an owner")
            icon: "thumb-up"
            onClicked: {
                var data = {
                    users: {}
                }
                data.users[activeUser] = 100
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
                PopupUtils.close(dialogue)
            }
            visible: canChangePermissions && activeUserPower != 100 && activeUserMembership !== "ban"
        }
        SettingsListItem {
            name: i18n.tr("Kick from this chat")
            icon: "dialog-warning-symbolic"
            onClicked: {
                matrix.post("/client/r0/rooms/" + activeChat + "/kick", { "user_id": activeUser } )
                PopupUtils.close(dialogue)
            }
            visible: canKick && activeUserMembership !== "leave" && activeUserMembership !== "ban"
        }
        SettingsListItem {
            name: i18n.tr("Ban from this chat")
            icon: "security-alert"
            onClicked: {
                matrix.post("/client/r0/rooms/" + activeChat + "/ban", { "user_id": activeUser } )
                PopupUtils.close(dialogue)
            }
            visible: canBan && activeUserMembership !== "ban"
        }
        SettingsListItem {
            name: i18n.tr("Cancel banishment")
            icon: "thumb-up"
            onClicked: {
                matrix.post("/client/r0/rooms/" + activeChat + "/unban", { "user_id": activeUser } )
                PopupUtils.close(dialogue)
            }
            visible: canBan && activeUserMembership === "ban"
        }
        SettingsListItem {
            name: i18n.tr("Forget user")
            icon: "edit-delete"
            onClicked: {
                matrix.post("/client/r0/rooms/" + activeChat + "/forget", { "user_id": activeUser } )
                PopupUtils.close(dialogue)
            }
            visible: activeUserMembership === "leave"
        }
        Row {
            width: parent.width
            spacing: units.gu(1)
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Show user")
                onClicked: {
                    PopupUtils.close(dialogue)
                    PopupUtils.open(userSettings)
                }
            }
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }
}
