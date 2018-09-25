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
        var localMainStack = mainStack
        matrix.post( "/client/r0/join/" + encodeURIComponent(matrixid), null, function ( response ) {
            loadingScreen.visible = true
            activeChat = response.room_id
            mainStack.toStart ()
            mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
        } )
    }

    ListItemLayout {
        id: layout
        title.text: displayname

        Avatar {
            name: displayname
            mxc: avatar_url
            width: units.gu(4)
            height: width
            SlotsLayout.position: SlotsLayout.Leading
        }
    }
}
