import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtContacts 5.0
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Start a new chat')

        trailingActionBar {
            actions: [
            Action {
                iconName: "contact-new"
                text: i18n.tr("Add Contact")
                onTriggered: contactImport.requestContact()
            },

            Action {
                iconName: "webbrowser-app-symbolic"
                text: i18n.tr("Discover public chats")
                onTriggered: mainStack.push(Qt.resolvedUrl("./JoinChatPage.qml"))
            }
            ]
        }
    }

    Component.onCompleted: {
        storage.transaction( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Contacts.medium, Contacts.address FROM Users, Contacts " +
        " WHERE Contacts.matrix_id=Users.matrix_id",
        function( res )  {
            for( var i = 0; i < res.rows.length; i++ ) {
                var user = res.rows[i]
                model.append({
                    matrixid: user.matrix_id,
                    name: user.displayname || usernames.transformFromId(user.matrix_id),
                    avatar_url: user.avatar_url,
                    medium: user.medium,
                    address: user.address,
                    temp: false
                })
            }
        })
    }

    ContactImport { id: contactImport }

    Column {
        id: addChatList
        width: mainStackWidth
        anchors.top: header.bottom

        SettingsListLink {
            name: i18n.tr("Create chat")
            icon: "message-new"
            page: "CreateChatPage"
        }

        Rectangle {
            width: parent.width
            height: units.gu(2)
            color: theme.palette.normal.background
        }
        Rectangle {
            width: parent.width
            height: searchField.height + units.gu(2)
            color: theme.palette.normal.background
            TextField {
                id: searchField
                objectName: "searchField"
                property var searchMatrixId: false
                property var upperCaseText: displayText.toUpperCase()
                property var tempElement: null
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: units.gu(2)
                    leftMargin: units.gu(2)
                }
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Search contacts or usernames...")
                onDisplayTextChanged: {
                    if ( tempElement !== null ) {
                        model.remove ( tempElement)
                        tempElement = null
                    }
                    if ( displayText.indexOf( "@" ) === -1 ||  displayText.length < 2 ) return
                        var input = displayText
                    if ( input.indexOf(":") === -1 ) {
                        input += ":" + settings.server
                    }
                    model.append ( {
                        matrixid: input,
                        address: input,
                        name: usernames.getById(input),
                        avatar_url: "",
                        medium: "matrix",
                        temp: true
                    })
                    tempElement = model.count - 1
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: UbuntuColors.ash
        }

        ListView {
            id: contactList
            width: parent.width
            height: root.height / 1.5
            delegate: ContactListItem { }
            model: ListModel { id: model }
            z: -1
            Button {
                anchors.centerIn: contactList
                color: UbuntuColors.green
                text: i18n.tr("Import from contacts")
                visible: model.count === 0
                onClicked: contactImport.requestContact()
            }
        }
    }
}
