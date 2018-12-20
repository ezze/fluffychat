import QtQuick 2.9
import Ubuntu.Components 1.3

Item {

    Connections {
        target: UriHandler
        onOpened: openUri ( uris )
    }

    function openUri ( uris ) {
        // no url
        if (uris.length === 0 ) return

        var uri = uris[0]
        uri = uri.replace("https://matrix.to/#/","fluffychat://")
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
        else console.error("Unkown uri...", uri)
    }

    function openUrlExternally ( link ) {
        if ( link.indexOf("fluffychat://") !== -1 ) uriController.openUri ( [link] )
        else if ( link.indexOf("https://matrix.to/#/") !== -1 ) uriController.openUri ( [link] )
        else if ( link.indexOf("http") !== -1 ) Qt.openUrlExternally ( link )
        else Qt.openUrlExternally ( "http://" + link )
    }

}
