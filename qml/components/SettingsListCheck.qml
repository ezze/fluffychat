import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    height: visible * layout.height
    visible: {
        selected ? true :
        (searchField.searchMatrixId ? matrixid.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
        : layout.title.text.toUpperCase().indexOf( searchField.upperCaseText ) !== -1)
    }
    property var isSelected: selected
    property var matrixid: matrix_id
    property var tempElement: temp
    selectMode: true
    onClicked: {
        selected = !selected
        if ( selected ) inviteList[inviteList.length] = matrixid
        else inviteList.splice( inviteList.indexOf(matrixid), 1 )
        if ( selected && tempElement ) searchField.tempElement = null
    }

    ListItemLayout {
        id: layout
        title.text: displayname
        title.color: mainFontColor

        Avatar {
            name: displayname
            mxc: avatar_url
            width: units.gu(4)
            height: width
            SlotsLayout.position: SlotsLayout.Leading
            onClickFunction: function () { usernames.showUserSettings ( matrix_id ) }
        }
    }
}
