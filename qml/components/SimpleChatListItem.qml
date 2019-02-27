import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/SimpleChatListItemActions.js" as ItemActions

ListItem {
    id: chatListItem

    color: mainLayout.darkmode ? "#202020" : "white"

    property var timeorder: 0
    property var previousMessage: ""
    property var room
    height: layout.height

    onClicked: mainLayout.toChat ( room.id )

    ListItemLayout {
        id: layout
        width: parent.width
        title.text: i18n.tr("Unknown chat")
        title.color: mainLayout.mainFontColor

        Avatar {
            id: avatar
            width: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
            name: room.topic || room.id
            mxc: room.avatar_url || ""
            onClickFunction: function () {}
        }

        Component.onCompleted: ItemActions.init ()
    }
}
