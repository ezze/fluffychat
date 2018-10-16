import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    property var enabled: true
    property var inviteList: []

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: FcPageHeader {
        id: header
        title: i18n.tr('Invite user')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "ok"
                text: i18n.tr("Invite selected")
                onTriggered: invite ( 0 )
            }
            ]
        }
    }

    function invite ( i ) {
        if ( i >= inviteList.length ) return mainStack.pop()
        enabled = false
        matrix.post ( "/client/r0/rooms/%1/invite".arg(activeChat),
        { user_id: inviteList[i] }, function () { invite( i+1 ) } )
    }

    Component.onCompleted: {
        storage.transaction( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url FROM Users, Contacts " +
        "WHERE Contacts.matrix_id=Users.matrix_id GROUP BY Users.matrix_id",
        function( res )  {
            for( var i = 0; i < res.rows.length; i++ ) {
                var user = res.rows[i]
                model.append({
                    matrix_id: user.matrix_id,
                    displayname: user.displayname || usernames.transformFromId(user.matrix_id),
                    avatar_url: user.avatar_url,
                    temp: false
                })
            }
        })
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
        placeholderText: i18n.tr("Search for example @username:server.abc")
        onDisplayTextChanged: {
            searchMatrixId = displayText.indexOf( "@" ) !== -1

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
        delegate: SettingsListCheck {}
        model: ListModel { id: model }
    }
}
