import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {

    height: visible * layout.height
    visible: {
        selected ? true :
        (searchField.searchMatrixId ? matrixid.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
        : layout.title.text.toUpperCase().indexOf( searchField.upperCaseText ) !== -1)
    }

    color: settings.darkmode ? "#202020" : "white"

    property var isSelected: selected
    property var matrixid: matrix_id
    property var tempElement: temp

    selectMode: true
    onClicked: {
        selected = !selected
        if ( selected ) inviteList[inviteList.length] = matrixid
        else inviteList.splice( inviteList.indexOf(matrixid), 1 )
        if ( selected && tempElement ) searchField.tempElement = null
        selectedCount = inviteList.length
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
                usernames.showUserSettings ( matrixid )
            }
        }
    }
}
