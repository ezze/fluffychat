import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent


    Component.onCompleted: init ()


    function init () {
        // Get all email addresses
        storage.transaction ( "SELECT address FROM ThirdPIDs WHERE medium='email'", function (response) {
            model.clear()
            for ( var i = 0; i < response.rows.length; i++ ) {
                model.append({
                    name: response.rows[ i ].address
                })
            }
        })
    }

    header: FcPageHeader {
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
