import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    id: chatListItem

    property var timeorder: 0
    property var previousMessage: ""
    property var room
    height: layout.height

    onClicked: {
        userSettingsViewer.collapse ()
        mainStack.toStart ()
        activeChat = room.id
        activeChatTypingUsers = []
        mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
        if ( room.notification_count > 0 ) matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + room.eventsid, null )
    }

    ListItemLayout {
        id: layout
        width: parent.width
        title.text: i18n.tr("Unknown chat")
        title.color: mainFontColor"

        Avatar {
            id: avatar
            SlotsLayout.position: SlotsLayout.Leading
            name: room.topic || room.id
            mxc: room.avatar_url || ""
            onClickFunction: function () {}
        }

        Component.onCompleted: {

            // Get the room name
            if ( room.topic !== "" ) layout.title.text = room.topic
            else roomnames.getById ( room.id, function (displayname) {
                layout.title.text = displayname
                avatar.name = displayname
                // Is there a typing notification?
                if ( room.typing && room.typing.length > 0 ) {
                    layout.subtitle.text = usernames.getTypingDisplayString ( room.typing, displayname )
                }
            })

            // Get the room avatar if single chat
            if ( avatar.mxc === "") roomnames.getAvatarFromSingleChat ( room.id, function ( avatar_url ) {
                avatar.mxc = avatar_url
            } )
        }
    }
}
