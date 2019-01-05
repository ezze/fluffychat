import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    visible: {
        searchField.upperCaseText === "" ? (membership === "join" || membership === "invite") :
        layout.title.text.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
    }
    height: visible ? layout.height : 0
    property var settings: (canBan || canKick || canChangePermissions) && (power > userPower || matrixid === settings.matrixid)
    property var status: usernames.powerlevelToStatus(userPower)

    onClicked: usernames.showUserSettings ( matrixid )

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainFontColor
        subtitle.text: membership !== "join" ? getDisplayMemberStatus ( membership ) : ""

        Avatar {
            id: avatar
            width: units.gu(4)
            height: width
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            mxc: avatar_url || ""
            opacity: membership === "join" ? 1 : 0.5
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

    Icon {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: units.gu(0.5)
        anchors.leftMargin: units.gu(1)
        name: status < 100 ? "unstarred" : "starred"
        visible: userPower >= 50
        width: units.gu(2)
        height: width
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
        // Make moderator button
        Action {
            iconName: "non-starred"
            onTriggered: showConfirmDialog( i18n.tr("Make this user a moderator?"), function () {
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
            onTriggered: showConfirmDialog( i18n.tr("Make this user an admin?"), function () {
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
