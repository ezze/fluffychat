import QtQuick 2.9
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
                mainStack.toChat ( uri )
            }
            else console.error("Unkown uri...")
        }
    }

}
