import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

ListItem {
    visible: {
        searchField.upperCaseText === "" ? (membership === "join" || membership === "invite") :
        layout.title.text.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
    }
    height: visible ? layout.height : 0
    property bool isUserItself: matrixid === matrix.matrixid
    property var settingsOn: (canBan || canKick || canChangePermissions) && (power > userPower || isUserItself)
    property var status: MatrixNames.powerlevelToStatus(userPower)
    color: mainLayout.darkmode ? "#202020" : "white"

    onClicked: MatrixNames.showUserSettings ( matrixid )

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainLayout.mainFontColor
        subtitle.text: membership !== "join" ? getDisplayMemberStatus ( membership ) : ""
        subtitle.color: mainLayout.mainFontColor

        Avatar {
            id: avatar
            width: units.gu(4)
            height: width
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            mxc: avatar_url || ""
            opacity: membership === "join" ? 1 : 0.5
            onClickFunction: function () {
                MatrixNames.showUserSettings ( matrixid )
            }
        }
        Icon {
            SlotsLayout.position: SlotsLayout.Trailing
            name: "filters"
            visible: settingsOn
            width: units.gu(2)
            height: width
            MouseArea {
                anchors.fill: parent
                onClicked: toast.show ( i18n.tr("Swipe to the left or the right for actions. 😉"))
            }
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
            iconName: "edit"
            onTriggered: {
                selectedUserId = matrixid
                contextualActions.show ()
            }
            visible: settingsOn && canChangePermissions && membership !== "ban"
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
            visible: settingsOn && canBan && membership !== "ban" && !isUserItself
        },
        // Unban button
        Action {
            iconName: "lock-broken"
            onTriggered: showConfirmDialog( i18n.tr("Cancel banishment?"), function () {
                matrix.post("/client/r0/rooms/" + activeChat + "/unban", { "user_id": matrixid } )
            })
            visible: settingsOn && canBan && membership === "ban" && !isUserItself
        },
        // Kick button
        Action {
            iconName: "edit-clear"
            onTriggered: showConfirmDialog( i18n.tr("Kick from this chat?"), function () {
                matrix.post("/client/r0/rooms/" + activeChat + "/kick", { "user_id": matrixid } )
            })
            visible: settingsOn && canKick && membership !== "leave" && membership !== "ban" && !isUserItself
        }
        ]
    }
}
