import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    id: publicChatListItem

    visible: { layout.title.text.toUpperCase().indexOf( searchField.displayText.toUpperCase() ) !== -1 }
    height: visible ? layout.height : 0

    color: mainLayout.darkmode ? "#202020" : "white"

    onClicked: mainLayout.toChat ( room.room_id )

    ListItemLayout {
        id: layout
        width: parent.width
        title.text: (room.name || room.room_id) + (room.num_joined_members !== undefined ? " (%1)".arg(room.num_joined_members) : "")
        title.font.bold: true
        title.color: mainLayout.mainFontColor
        subtitle.text: room.topic || ""
        subtitle.color: "#888888"
        subtitle.linkColor: subtitle.color

        Avatar {
            id: avatar
            SlotsLayout.position: SlotsLayout.Leading
            name: layout.title.text
            mxc: room.avatar_url || ""
            onClickFunction: function () { mainLayout.toChat ( room.room_id ) }
        }
    }
}
