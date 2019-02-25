import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

StyledPage {
    anchors.fill: parent

    property var canEditAddresses: false
    property var canEditCanonicalAlias: false
    property var addresses: []


    Component.onCompleted: init ()

    Connections {
        target: matrix
        onNewEvent: update ( type, chat_id, eventType, eventContent )
    }

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    function update ( type, chat_id, eventType, eventContent ) {
        if ( activeChat !== chat_id ) return
        var matchTypes = [ "m.room.aliases", "m.room.canonical_alias" ]
        if ( matchTypes.indexOf( type ) !== -1 ) init ()
    }

    function init () {
        storage.transaction ( "SELECT Chats.canonical_alias, Chats.power_event_canonical_alias, Chats.power_event_aliases, Memberships.power_level " +
        " FROM Chats, Memberships WHERE " +
        " Chats.id='" + activeChat + "' AND " +
        " Memberships.chat_id='" + activeChat + "' AND " +
        " Memberships.matrix_id='" + matrix.matrixid + "'", function ( res ) {
            canEditCanonicalAlias = res.rows[0].power_event_canonical_alias <= res.rows[0].power_level
            canEditAddresses = res.rows[0].power_event_aliases <= res.rows[0].power_level
            var canonical_alias = res.rows[0].canonical_alias

            // Get all addresses
            storage.transaction ( "SELECT address FROM Addresses WHERE chat_id='" + activeChat + "'", function (response) {
                addresses = response.rows

                model.clear()
                for ( var i = 0; i < response.rows.length; i++ ) {
                    console.log(response.rows[i].address)
                    model.append({
                        name: response.rows[ i ].address,
                        isCanonicalAlias: response.rows[ i ].address === canonical_alias
                    })
                }
                if ( response.rows.length === 0 ) PopupUtils.open( addAliasDialog )
            })
        })
    }

    header: PageHeader {
        id: header
        title:  i18n.tr('Public chat addresses')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "insert-link"
                text: i18n.tr("Add chat address")
                onTriggered: PopupUtils.open( addAliasDialog )
                visible: canEditAddresses
            }
            ]
        }
    }

    AddAliasDialog { id: addAliasDialog }

    ListView {
        id: addressesList
        anchors.top: header.bottom
        width: parent.width
        height: root.height / 1.5
        delegate: AddressesListItem { }
        model: ListModel { id: model }
    }

}
