import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    function success_callback ( response ) {
        activeChat = response.room_id
        if ( mainStack.depth === 1 ) bottomEdge.collapse()
        else mainStack.pop ()
        mainStack.push (Qt.resolvedUrl("./ChatPage.qml"))
    }


    function joinRoom () {
        var newChatId = searchTextField.displayText
        errorReport.text = ""
        if ( newChatId === "" ) searchTextField.focus = true
        else {
            var success_callback = function ( response ) {
                toast.show ( i18n.tr("Synchronizing\nThis can take a few minutes…") )
                searchTextField.text = ""
                activeChat = response.room_id
                if ( mainStack.depth === 1 ) bottomEdge.collapse()
                else mainStack.pop ()
                mainStack.push (Qt.resolvedUrl("./ChatPage.qml"))
            }
            var error_callback = function ( error ) {
                var errcodes = {
                    "M_UNKNOWN": i18n.tr("Could not find room 😟"),
                }
                errorReport.text = error.errcode in errcodes ? errcodes[error.errcode] : error.error
            }
            events.waitForSync ()
            matrix.post("/client/r0/join/" + encodeURIComponent(newChatId), null, success_callback, error_callback)
        }

    }

    header: FcPageHeader {
        title: i18n.tr('New chat')
    }

    NewContactDialog{ id: newContactDialog }
    NewGroupDialog{ id: newGroupDialog }
    JoinGroupDialog{ id: joinGroupDialog }

    Column {
        id: addChatList
        width: mainStackWidth
        anchors.top: header.bottom

        SettingsListItem {
            name: i18n.tr("New contact")
            icon: "contact-new"
            onClicked: PopupUtils.open(newContactDialog)
        }

        SettingsListItem {
            name: i18n.tr("New group")
            icon: "contact-group"
            onClicked: PopupUtils.open(newGroupDialog)
        }

        SettingsListItem {
            name: i18n.tr("Join group")
            icon: "user-admin"
            onClicked: PopupUtils.open(joinGroupDialog)
        }
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height - addChatList.height
        anchors.top: addChatList.bottom
        anchors.topMargin: units.gu(1)

        contentItem: Grid {
            id: rosterGrid
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}
