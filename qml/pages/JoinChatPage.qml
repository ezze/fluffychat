import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    id: page

    property var enabled: false
    property var inviteList: []

    header: FcPageHeader {
        id: header
        title: i18n.tr('Join chat')
    }

    Component.onCompleted: {
        matrix.get ( "/client/r0/publicRooms", { limit: 1000 }, function ( res ) {
            for( var i = 0; i < res.chunk.length; i++ ) {
                var chat = res.chunk[i]
                model.append({
                    matrix_id: chat.room_id,
                    displayname: chat.name || i18n.tr("Nameless chat"),
                    avatar_url: chat.avatar_url || ""
                })
            }
            enabled = true
        } )
    }

    TextField {
        id: searchField
        objectName: "searchField"
        property var searchMatrixId: false
        property var upperCaseText: displayText.toUpperCase()
        property var tempElement: null
        z: 5
        anchors {
            top: header.bottom
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }
        readOnly: !enabled
        focus: true
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search public chats...")
        onDisplayTextChanged: {
            searchMatrixId = displayText.indexOf( "#" ) !== -1

            if ( searchMatrixId && displayText.indexOf(":") !== -1 ) {
                if ( tempElement !== null ) {
                    model.remove ( tempElement)
                    tempElement = null
                }
                model.append ( {
                    matrix_id: displayText,
                    displayname: displayText,
                    avatar_url: "",
                    temp: true
                })
                tempElement = model.count - 1
            }
        }
    }

    ActivityIndicator {
        visible: !enabled
        running: visible
        anchors.centerIn: parent
    }

    ListView {
        opacity: enabled ? 1 : 0.5
        id: chatListView
        width: parent.width
        height: parent.height - header.height - searchField.height
        anchors.top: searchField.bottom
        delegate: PublicChatItem {}
        model: ListModel { id: model }
        Label {
            anchors.centerIn: chatListView
            text: i18n.tr("Loading public chats...")
            visible: !page.enabled
        }
    }
}
