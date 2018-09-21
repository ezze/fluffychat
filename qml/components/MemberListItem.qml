import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {

    visible: { layout.title.text.toUpperCase().indexOf( searchField.displayText.toUpperCase() ) !== -1 }
    height: visible ? layout.height : 0
    property var settings: (canBan || canKick || canChangePermissions) && (power > userPower || matrixid === matrix.matrixid)
    property var status: usernames.powerlevelToStatus(userPower)

    onClicked: usernames.showUserSettings ( matrixid )

    opacity: membership === "join" ? 1 : 0.5

    ListItemLayout {
        id: layout
        title.text: name
        subtitle.text: membership === "join" ? status : getDisplayMemberStatus ( membership )

        Avatar {
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            mxc: avatar_url || ""
            onClickFunction: function () {
                usernames.showUserSettings ( matrixid )
            }
        }
        Icon {
            SlotsLayout.position: SlotsLayout.Trailing
            name: "sort-listitem"
            visible: settings
            width: units.gu(3)
            height: width
            rotation: 90
        }
    }



    // Settings Buttons
    trailingActions: ListItemActions {
        actions: [
        // Make member button
        Action {
            iconName: "contact"
            onTriggered: showConfirmDialog( i18n.tr("Make this user a normal member?"), function () {
                var data = {
                    users: {}
                }
                data.users[matrixid] = 0
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
            })
            visible: canChangePermissions && userPower != 0 && membership !== "ban"
        },
        // Make guard button
        Action {
            iconName: "non-starred"
            onTriggered: showConfirmDialog( i18n.tr("Make this user a guard?"), function () {
                var data = {
                    users: {}
                }
                data.users[matrixid] = 50
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
            })
            visible: canChangePermissions && userPower != 50 && membership !== "ban"
        },
        // Make owner button
        Action {
            iconName: "starred"
            onTriggered: showConfirmDialog( i18n.tr("Make this user an owner?"), function () {
                var data = {
                    users: {}
                }
                data.users[matrixid] = 100
                matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
            })
            visible: canChangePermissions && userPower != 100 && membership !== "ban"
        }
        ]
    }

    // Kick & ban Buttons
    leadingActions: ListItemActions {
        actions: [
        // Ban button
        Action {
            iconName: "system-lock-screen"
            onTriggered: showConfirmDialog( i18n.tr("Ban from this chat?"), function () {
                matrix.post("/client/r0/rooms/" + activeChat + "/ban", { "user_id": matrixid } )
            })
            visible: canBan && membership !== "ban"
        },
        // Unban button
        Action {
            iconName: "lock-broken"
            onTriggered: showConfirmDialog( i18n.tr("Cancel banishment?"), function () {
                matrix.post("/client/r0/rooms/" + activeChat + "/unban", { "user_id": matrixid } )
            })
            visible: canBan && membership === "ban"
        },
        // Kick button
        Action {
            iconName: "edit-clear"
            onTriggered: showConfirmDialog( i18n.tr("Kick from this chat?"), function () {
                matrix.post("/client/r0/rooms/" + activeChat + "/kick", { "user_id": matrixid } )
            })
            visible: canKick && membership !== "leave" && membership !== "ban"
        }
        ]
    }
}
