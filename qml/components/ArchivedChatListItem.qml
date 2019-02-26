import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

ListItem {
    id: chatListItem

    color: mainLayout.darkmode ? "#202020" : "white"

    property var timeorder: 0

    visible: { layout.title.text.toUpperCase().indexOf( searchField.displayText.toUpperCase() ) !== -1 }
    height: visible ? layout.height : 0

    onClicked: mainLayout.toChat (room.id)

    ListItemLayout {
        id: layout
        title.text: i18n.tr("Unknown chat")
        title.font.bold: true
        title.color: room.membership === "invite" ? mainLayout.mainColor : mainLayout.mainFontColor

        Avatar {
            id: avatar
            SlotsLayout.position: SlotsLayout.Leading
            name: room.topic || room.id
            mxc: room.avatar_url || ""
        }

        Component.onCompleted: {
            // Get the room name
            if ( room.topic !== "" ) layout.title.text = room.topic
            else MatrixNames.getChatAvatarById ( room.id, function (displayname) {
                layout.title.text = displayname
                avatar.name = displayname
            })

            // Get the room avatar if single chat
            if ( avatar.mxc === "") MatrixNames.getAvatarFromSingleChat ( room.id, function ( avatar_url ) {
                avatar.mxc = avatar_url
            } )
        }
    }


    Label {
        id: stampLabel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.gu(2)
        text: MatrixNames.getChatTime ( room.origin_server_ts )
        textSize: Label.XSmall
        visible: text != ""
    }

    // Delete Button
    leadingActions: ListItemActions {
        actions: [
        Action {
            iconName: "edit-delete"
            onTriggered: {
                matrix.post( "/client/r0/rooms/%1/forget".arg(room.id) )
                storage.query ( "DELETE FROM Memberships WHERE chat_id=?", [ room.id ] )
                storage.query ( "DELETE FROM Events WHERE chat_id=?", [ room.id ] )
                storage.query ( "DELETE FROM Chats WHERE id=?", [ room.id ] )
                archivedChatListPage.update ()
            }
        }
        ]
    }


}
