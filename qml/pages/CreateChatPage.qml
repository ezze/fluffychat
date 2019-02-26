import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

StyledPage {
    id: createChatPage
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr('Add Chat')

        trailingActionBar {
            actions: [
            Action {
                id: newContactAction
                iconName: "contact-new"
                text: i18n.tr("Import from addressbook")
                onTriggered: PopupUtils.open(addContactDialog)
            }
            ]
        }

        contents: TextField {
            id: searchField
            objectName: "searchField"
            property var searchMatrixId: false
            property var upperCaseText: displayText.toUpperCase()
            primaryItem: Icon {
                height: parent.height - units.gu(2)
                name: "find"
                anchors.left: parent.left
                anchors.leftMargin: units.gu(0.25)
            }
            width: parent.width - units.gu(2)
            anchors.centerIn: parent
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Filter contacts")
        }
    }

    Connections {
        target: matrix
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
        var res = storage.query( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Users.presence, Users.last_active_ago, Contacts.medium, Contacts.address FROM Users LEFT JOIN Contacts " +
        " ON Contacts.matrix_id=Users.matrix_id WHERE Users.matrix_id!=? ORDER BY Contacts.medium DESC, LOWER(Users.displayname || replace(Users.matrix_id,'@','')) LIMIT 1000", [
        matrix.matrixid ] )
        for( var i = 0; i < res.rows.length; i++ ) {
            var user = res.rows[i]
            model.append({
                matrix_id: user.matrix_id,
                name: user.displayname || MatrixNames.transformFromId(user.matrix_id),
                avatar_url: user.avatar_url,
                medium: user.medium || "matrix",
                address: user.address || user.matrix_id,
                last_active_ago: user.last_active_ago,
                presence: user.presence,
                temp: false
            })
        }
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
                            mainLayout.toChat ( response.room_id, true )
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
                    bottomEdge.collapse ()
                    mainLayout.addPageToCurrentColumn ( layout.primaryPage, Qt.resolvedUrl("./DiscoverPage.qml") )
                }
                anchors.bottom: parent.bottom
            }
        }
    }

    Label {
        text: i18n.tr("Click on the top right button to add contacts.")
        textSize: Label.Large
        color: UbuntuColors.graphite
        anchors.centerIn: chatListView
        width: parent.width - units.gu(4)
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        wrapMode: Text.Wrap
        z: -1
    }

    ContactImport {
        id: contactImport
        onImportCompleted: createChatPage.update ()
    }

    AddContactDialog { id: addContactDialog }

}
