import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var canEditAddresses: false
    property var canEditCanonicalAlias: false


    Component.onCompleted: init ()

    Connections {
        target: events
        onChatTimelineEvent: init ()
    }

    function init () {
        /*storage.transaction ( "SELECT Chats.power_state_default, Chats.power_event_aliases, Memberships.power_level " +
        " FROM Chats, Memberships WHERE " +
        " Chats.chat_id='" + activeChat + "' AND " +
        " Memberships.chat_id='" + activeChat + "' AND " +
        " Memberships.matrix_id='" + matrix.matrixid + "'", function ( res ) {

        }*/
        // Get all addresses
        storage.transaction ( "SELECT address FROM Addresses WHERE chat_id='" + activeChat + "'", function (response) {
            for ( var i = 0; i < response.rows.length; i++ ) {
                var item = Qt.createComponent("../components/SettingsListItem.qml")
                item.createObject(content, {
                    name: response.rows[ i ].address,
                    icon: "bookmark",
                    onTriggered: console.log("tja ...")
                })
            }
        })
    }

    header: FcPageHeader {
        title:  i18n.tr('Public chat addresses')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "add"
                text: i18n.tr("Add chat address")
                onTriggered: console.log("tja ...")
            }
            ]
        }
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            id: content
            width: mainStackWidth
        }
    }

}
