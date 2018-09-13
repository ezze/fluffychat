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
    selectMode: true
    onClicked: selected = !selected

    ListItemLayout {
        id: layout
        title.text: displayname

        Avatar {
            name: displayname
            mxc: avatar_url
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
            onClickFunction () { usernames.showUserSettings ( event.sender ) }
        }
    }
}
