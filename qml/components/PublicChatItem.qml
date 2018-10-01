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
    property var matrixid: matrix_id
    onClicked: {
        storage.transaction ( "SELECT * FROM Chats WHERE id='" + matrixid + "'", function (rs) {
            if ( rs.rows.length > 0 ) {
                activeChat = matrixid
                mainStack.toStart ()
                mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
            }
            else matrix.joinChat ( matrixid )
        })
    }

    ListItemLayout {
        id: layout
        title.text: displayname
        title.color: mainFontColor"

        Avatar {
            name: displayname
            mxc: avatar_url
            width: units.gu(4)
            height: width
            SlotsLayout.position: SlotsLayout.Leading
        }
    }
}
