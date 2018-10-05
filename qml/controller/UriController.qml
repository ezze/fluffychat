import QtQuick 2.4
import Ubuntu.Components 1.3

Item {

    Connections {
        target: UriHandler
        onOpened: {
            // no url
            if (uris.length === 0 ) return

            var uri = uris[0]
            if ( uri.slice(0,14) === "fluffychat://@" ) {
                uri = uri.replace("fluffychat://","")
                usernames.handleUserUri( uri )
            }
            else if ( uri.slice(0,14) === "fluffychat://#" ) {
                uri = uri.replace("fluffychat://","")
                matrix.joinChat ( uri )
            }
            else if ( uri.slice(0,14) === "fluffychat://!" ) {
                uri = uri.replace("fluffychat://","")
                mainStack.toStart ()
                activeChat = uri
                mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
                if ( room.notification_count > 0 ) matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + room.eventsid, null )
            }
            else console.error("Unkown uri...")
        }
    }

}
