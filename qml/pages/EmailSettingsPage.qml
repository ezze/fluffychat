import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

StyledPage {
    id: emailSettingsPage
    anchors.fill: parent


    Component.onCompleted: sync ()


    function sync () {
        update()

        // Check for updates online
        matrix.get( "/client/r0/account/3pid", null, function ( res ) {
            storage.query ( "DELETE FROM ThirdPIDs")
            if ( res.threepids.length === 0 ) return
            for ( var i = 0; i < res.threepids.length; i++ ) {
                storage.query ( "INSERT OR IGNORE INTO ThirdPIDs VALUES( ?, ? )", [ res.threepids[i].medium, res.threepids[i].address ] )
            }
            update()
        })
    }


    function update () {
        // Get all email addresses
        var response = storage.query ( "SELECT address FROM ThirdPIDs WHERE medium='email'" )
        model.clear()
        for ( var i = 0; i < response.rows.length; i++ ) {
            model.append({
                name: response.rows[ i ].address
            })
        }
    }

    header: PageHeader {
        id: header
        title:  i18n.tr('Connected email addresses')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "add"
                text: i18n.tr("Add email address")
                onTriggered: PopupUtils.open( addEmailDialog )
            }
            ]
        }
    }

    AddEmailDialog { id: addEmailDialog }

    Label {
        anchors.centerIn: addressesList
        text: i18n.tr("No email addresses connected")
        visible: model.count === 0
    }

    ListView {
        id: addressesList
        anchors.top: header.bottom
        width: parent.width
        height: parent.height - header.height
        delegate: EmailListItem { }
        model: ListModel { id: model }
        z: -1
    }

}
