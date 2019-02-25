import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent
    id: discoverPage

    property var loading: true

    // Add public rooms from a server side search to the model.
    function addPublicRoomsToModel ( res ) {
        for( var i = 0; i < res.chunk.length; i++ ) {
            model.append ( { "room": res.chunk[i] } )
        }
    }


    function handleError ( error ) {
        loading = false
        label.text = error.error
    }

    Component.onCompleted: {

        // Set the limit
        var limit = 400

        // Search for public rooms on the homeserver
        matrix.get ( "/client/r0/publicRooms", { "limit": limit }, function ( res ) {
            addPublicRoomsToModel ( res )
            // Also search on matrix.org if not already
            if ( matrix.server !== "matrix.org" ) {
                matrix.get ( "/client/r0/publicRooms", { "limit": limit, "server": "matrix.org" }, function ( res ) {
                    addPublicRoomsToModel ( res )
                    loading = false
                }, handleError, 1 )
            }
            else loading = false
        }, handleError, 1 )

    }


    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: PageHeader {
        id: header
        title: i18n.tr("Groups on %1").arg(matrix.server) + (matrix.server !== "matrix.org" ? " " + i18n.tr("and matrix.org") : "")
        flickable: chatListView

        contents: TextField {
            id: searchField
            objectName: "searchField"
            z: 5
            property var searchMatrixId: false
            property var upperCaseText: displayText.toUpperCase()
            property var tempElement: null
            primaryItem: Icon {
                height: parent.height - units.gu(2)
                name: "find"
                anchors.left: parent.left
                anchors.leftMargin: units.gu(0.25)
            }
            width: parent.width - units.gu(2)
            anchors.centerIn: parent
            onDisplayTextChanged: {
                if ( tempElement ) {
                    model.remove ( model.count - 1 )
                    tempElement  = false
                }

                if ( displayText.slice( 0,1 ) === "#" ) {
                    searchMatrixId = displayText
                    if ( searchMatrixId.indexOf(":") === -1 ) searchMatrixId += ":%1".arg(matrix.server)


                    model.append ( { "room": {
                        id: searchMatrixId,
                        topic: searchMatrixId,
                        membership: "leave",
                        avatar_url: "",
                        origin_server_ts: new Date().getTime(),
                        typing: [],
                        notification_count: 0,
                        highlight_count: 0
                    } } )
                    tempElement = true
                }
            }
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search for chats or #aliases...")
        }
    }




    ListModel { id: model }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        delegate: PublicChatListItem {}
        model: model
        move: Transition {
            SmoothedAnimation { property: "y"; duration: 300 }
        }
        displaced: Transition {
            SmoothedAnimation { property: "y"; duration: 300 }
        }
    }

    Label {
        id: label
        text: loading ? i18n.tr("Loading...") : i18n.tr("No chats found")
        textSize: Label.Large
        color: UbuntuColors.graphite
        anchors.centerIn: parent
        visible: loading || model.count === 0
    }

}
