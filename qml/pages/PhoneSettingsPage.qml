import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent


    Component.onCompleted: init ()


    function init () {
        // Get all phone numbers
        storage.transaction ( "SELECT address FROM ThirdPIDs WHERE medium='msisdn'", function (response) {
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
        title:  i18n.tr('Connected phone numbers')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "add"
                text: i18n.tr("Add phone number")
                onTriggered: PopupUtils.open( addPhoneDialog )
            }
            ]
        }
    }

    AddPhoneDialog { id: addPhoneDialog }

    Label {
        anchors.centerIn: addressesList
        text: i18n.tr("No phone numbers connected")
        visible: model.count === 0
    }

    ListView {
        id: addressesList
        anchors.top: header.bottom
        width: parent.width
        height: parent.height - header.height
        delegate: PhoneListItem { }
        model: ListModel { id: model }
        z: -1
    }

}
