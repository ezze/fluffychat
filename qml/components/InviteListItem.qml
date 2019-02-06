import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

ListItem {

    height: visible * layout.height
    visible: {
        searchField.searchMatrixId ? matrixid.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
        : layout.title.text.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
    }

    color: settings.darkmode ? "#202020" : "white"

    property var matrixid: matrix_id
    property var displayname: name
    property var tempElement: temp

    onClicked: {
        var inviteAction = function () {
            // Invite this user
            matrix.post ( "/client/r0/rooms/%1/invite".arg(activeChat),{ user_id: matrixid }, function () {
                toast.show( i18n.tr('%1 has been invited').arg(displayname) )
            }, function ( error) {
                if ( error.errcode === "M_UNKNOWN" ) toast.show ( i18n.tr('An error occured. Maybe the username %1 is wrong?').arg(matrixid) )
                else if ( error.errcode === "M_FORBIDDEN" ) toast.show ( i18n.tr('%1 is banned from the chat.').arg(matrixid) )
                else toast.show ( error.error )
            } )
        }
        showConfirmDialog ( i18n.tr("Invite %1 to this chat?"), inviteAction)
    }

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainFontColor
        subtitle.text: medium.replace("msisdn","📱").replace("email","✉").replace("matrix","💬") + " " + address
        subtitle.color: "#888888"

        Avatar {
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            width: units.gu(4)
            height: width
            mxc: avatar_url || ""
            onClickFunction: function () {
                MatrixNames.showUserSettings ( matrixid )
            }
        }
        Icon {
            SlotsLayout.position: SlotsLayout.Trailing
            width: units.gu(2)
            height: width
            name: "contact-new"
        }
    }
}
