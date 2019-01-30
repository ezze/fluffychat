import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    header: FcPageHeader {
        id: header
        title: i18n.tr('Invite users')
        flickable: chatListView

        extension: Rectangle {
            width: parent.width
            height: searchField.height + units.gu(1)
            color: theme.palette.normal.background
            anchors.bottom: parent.bottom
            TextField {
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
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    rightMargin: units.gu(2)
                    leftMargin: units.gu(2)
                }
                focus: true
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Search for example @username:server.abc")
                onDisplayTextChanged: {
                    searchMatrixId = displayText.slice( 0,1 ) === "@"

                    if ( searchMatrixId && displayText.indexOf(":") !== -1 ) {
                        if ( tempElement !== null ) {
                            model.remove ( tempElement)
                            tempElement = null
                        }
                        model.append ( {
                            matrix_id: displayText,
                            name: usernames.transformFromId(displayText),
                            medium: "matrix",
                            address: displayText,
                            avatar_url: "",
                            temp: true
                        })
                        tempElement = model.count - 1
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        storage.transaction( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Contacts.medium, Contacts.address FROM Users LEFT JOIN Contacts " +
        " ON Contacts.matrix_id=Users.matrix_id ORDER BY Contacts.medium DESC LIMIT 1000",
        function( res )  {
            for( var i = 0; i < res.rows.length; i++ ) {
                var user = res.rows[i]
                if ( activeChatMembers[user.matrix_id] !== undefined ) continue
                model.append({
                    matrix_id: user.matrix_id,
                    name: user.displayname || usernames.transformFromId(user.matrix_id),
                    avatar_url: user.avatar_url,
                    medium: user.medium || "matrix",
                    address: user.address || user.matrix_id,
                    temp: false
                })
            }
        })
    }



    ListView {
        id: chatListView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        delegate: InviteListItem {}
        model: ListModel { id: model }
    }
}
