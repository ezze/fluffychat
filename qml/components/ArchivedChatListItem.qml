import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/ArchivedChatListItemActions.js" as ItemActions

ListItem {
    id: chatListItem

    color: mainLayout.darkmode ? "#202020" : "white"

    property var timeorder: 0

    visible: { layout.title.text.toUpperCase().indexOf( searchField.displayText.toUpperCase() ) !== -1 }
    height: visible ? layout.height : 0

    onClicked: mainLayout.toChat (room.id)

    ListItemLayout {
        id: layout
        title.text: room.topic || MatrixNames.getChatAvatarById ( room.id )
        title.font.bold: true
        title.color: room.membership === "invite" ? mainLayout.mainColor : mainLayout.mainFontColor

        Avatar {
            id: avatar
            SlotsLayout.position: SlotsLayout.Leading
            name: title.text
            mxc: room.avatar_url || MatrixNames.getAvatarFromSingleChat ( room.id )
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
            onTriggered: ItemActions.clear ( room.id )
        }
        ]
    }


}
