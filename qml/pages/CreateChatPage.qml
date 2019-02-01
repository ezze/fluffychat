import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    id: createChatPage
    anchors.fill: parent

    header: StyledPageHeader {
        id: header
        title: i18n.tr('Add Chat')

        trailingActionBar {
            actions: [
            Action {
                id: newContactAction
                iconName: "contact-new"
                text: i18n.tr("Import from addressbook")
                onTriggered: contactImport.requestContact()
            }
            ]
        }

        contents: TextField {
            id: searchField
            objectName: "searchField"
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
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search e.g. @username:server.abc")
            onDisplayTextChanged: {

                if ( displayText.slice( 0,1 ) === "@" && displayText.length > 1 ) {
                    var input = displayText
                    if ( input.indexOf(":") === -1 ) {
                        input += ":" + settings.server
                    }
                    if ( tempElement !== null ) {
                        model.remove ( tempElement)
                        tempElement = null
                    }
                    if ( input.split(":").length > 2 || input.split("@").length > 2 || displayText.length < 2 ) return
                    model.append ( {
                        matrix_id: input,
                        medium: "matrix",
                        name: input,
                        address: input,
                        avatar_url: "",
                        last_active_ago: 0,
                        presence: "offline",
                        temp: true
                    })
                    tempElement = model.count - 1
                }
            }
        }
    }

    Connections {
        target: events
        //onNewEvent: updatePresence ( type, chat_id, eventType, eventContent )
    }

    function updatePresence ( type, chat_id, eventType, eventContent ) {
        if ( type === "m.presence" ) {
            for ( var i = 0; i < model.count; i++ ) {
                if ( model.get(i).matrix_id === eventContent.sender ) {
                    model.set(i).presence = eventContent.presence
                    if ( eventContent.last_active_ago ) model.set(i).last_active_ago = eventContent.last_active_ago
                    break
                }
            }
        }
    }

    Connections {
        target: bottomEdge
        onCommitCompleted: update ()
        onCollapseCompleted: model.clear()
    }

    function update () {
        model.clear()
        storage.transaction( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Users.presence, Users.last_active_ago, Contacts.medium, Contacts.address FROM Users LEFT JOIN Contacts " +
        " ON Contacts.matrix_id=Users.matrix_id WHERE Users.matrix_id!='" + settings.matrixid + "' ORDER BY Contacts.medium DESC, LOWER(Users.displayname || replace(Users.matrix_id,'@','')) LIMIT 1000",
        function( res )  {
            for( var i = 0; i < res.rows.length; i++ ) {
                var user = res.rows[i]
                model.append({
                    matrix_id: user.matrix_id,
                    name: user.displayname || usernames.transformFromId(user.matrix_id),
                    avatar_url: user.avatar_url,
                    medium: user.medium || "matrix",
                    address: user.address || user.matrix_id,
                    last_active_ago: user.last_active_ago,
                    presence: user.presence,
                    temp: false
                })
            }
        })
    }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        delegate: ContactListItem {}
        model: ListModel { id: model }

        header: Rectangle {
            width: chatListView.width
            height: settingsListFooter.height * 2
            SettingsListFooter {
                id: settingsListFooter
                icon: "contact-group"
                name: i18n.tr("New group")
                iconWidth: units.gu(4)
                onClicked: {
                    var createNewGroup = function () {
                        matrix.post( "/client/r0/createRoom", {
                            preset: "private_chat"
                        }, function ( response ) {
                            toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
                            mainStack.toChat ( response.room_id )
                            mainStack.push(Qt.resolvedUrl("./InvitePage.qml"))
                        }, null, 2 )
                    }
                    showConfirmDialog ( i18n.tr("Do you want to create a new group now?"), createNewGroup )
                }
                anchors.top: parent.top
            }
            SettingsListFooter {
                icon: "find"
                name: i18n.tr("Public groups")
                iconWidth: units.gu(4)
                onClicked: {
                    mainStack.toStart ("./pages/DiscoverPage.qml")
                }
                anchors.bottom: parent.bottom
            }
        }
    }

    ContactImport {
        id: contactImport
        onImportCompleted: createChatPage.update ()
    }

}
