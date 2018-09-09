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

    onClicked: {
        if ( settings ) {
            activeUser = matrixid
            activeUserPower = userPower
            activeUserMembership = membership
            PopupUtils.open(changeMemberStatusDialog)
        }
        else {
            activeUser = matrixid
            PopupUtils.open(userSettings)
        }
    }

    opacity: membership === "join" ? 1 : 0.5

    ListItemLayout {
        id: layout
        title.text: name
        subtitle.text: membership === "join" ? status.substring(0, status.length - 1) : getDisplayMemberStatus ( membership )

        Avatar {
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            mxc: avatar_url !== undefined ? avatar_url : ""
            onClickFunction: function () {
                activeUser = matrixid
                PopupUtils.open(userSettings)
            }
        }

        Icon {
            SlotsLayout.position: SlotsLayout.Trailing
            name: "settings"
            visible: settings
            width: units.gu(2)
            height: width
        }

    }
}
