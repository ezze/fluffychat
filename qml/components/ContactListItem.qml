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
    color: mainLayout.darkmode ? "#202020" : "white"

    property var matrixid: matrix_id
    property var tempElement: temp
    property var presenceStr: last_active_ago !== 0 ? i18n.tr("Last active: %1").arg( MatrixNames.getChatTime ( last_active_ago ) ) : presence

    onSelectedChanged: {
        if ( selected ) inviteList[inviteList.length] = matrixid
        else inviteList.splice( inviteList.indexOf(matrixid), 1 )
        if ( selected && tempElement ) searchField.tempElement = null
        selectedCount = inviteList.length
    }

    onClicked: MatrixNames.showUserSettings ( matrixid )

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainLayout.mainFontColor
        subtitle.text: presenceStr
        subtitle.color: mainLayout.mainFontColor

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
            name: medium==="msisdn" ? "phone-smartphone-symbolic" :
            ( medium==="email" ? "dekko-app-symbolic" :
            ( "messaging-app-symbolic" ) )
            SlotsLayout.position: SlotsLayout.Trailing
            width: units.gu(3)
            height: width
        }

    }
}
