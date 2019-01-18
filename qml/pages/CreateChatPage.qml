import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    property var inviteList: []
    property var selectedCount: 0

    header: FcPageHeader {
        id: header
        title: selectedCount===0 ? i18n.tr('Add chat') : i18n.tr('New chat: %1 selected').arg(selectedCount)

        trailingActionBar {
            actions: [
            Action {
                id: newContactAction
                iconName: "contact-new"
                text: i18n.tr("Add from addressbook")
                onTriggered: contactImport.requestContact()
            }
            ]
        }
    }

    Rectangle {
        anchors.fill: parent
        color: settings.darkmode ? "#202020" : "white"
        z: -2
    }

    Connections {
        target: events
        onNewEvent: updatePresence ( type, chat_id, eventType, eventContent )
    }

    function updatePresence ( type, chat_id, eventType, eventContent ) {
        if ( type === "m.presence" ) {
            for ( var i = 0; i < model.count; i++ ) {
                if ( model.get(i).matrix_id === eventContent.sender ) {
                    model.set(i).matrix_id = eventContent.presence
                    if ( eventContent.last_active_ago ) model.set(i).last_active_ago = eventContent.last_active_ago
                    break
                }
            }
        }
    }

    Component.onCompleted: update ()

    function update () {
        storage.transaction( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Users.presence, Users.last_active_ago, Contacts.medium, Contacts.address FROM Users LEFT JOIN Contacts " +
        " ON Contacts.matrix_id=Users.matrix_id WHERE Users.matrix_id!='" + settings.matrixid + "' ORDER BY Contacts.medium DESC LIMIT 1000",
        function( res )  {
            for( var i = 0; i < res.rows.length; i++ ) {
                var user = res.rows[i]
                model.append({
                    matrix_id: user.matrix_id,
                    name: user.displayname || usernames.transformFromId(user.matrix_id),
                    avatar_url: user.avatar_url,
                    medium: user.medium || "matrix",
                    address: user.address || user.matrix_id,
                    last_active_ago: user.last_active_ago,
                    presence: user.presence,
                    temp: false
                })
            }
        })
    }

    Column {
        id: contentColumn
        z: 1
        width: parent.width
        anchors.top: header.bottom

        ListItem {
            height: layout.height
            onClicked: mainStack.push(Qt.resolvedUrl("../pages/DiscoverPage.qml"))

            ListItemLayout {
                id: layout
                title.text: i18n.tr("Join public chat")
                title.color: settings.darkmode ? "white" : "black"
                Icon {
                    source: "../../assets/hashtag.svg"
                    width: units.gu(3)
                    height: width
                    SlotsLayout.position: SlotsLayout.Leading
                }
                Icon {
                    name: "toolkit_chevron-ltr_4gu"
                    width: units.gu(3)
                    height: units.gu(3)
                    SlotsLayout.position: SlotsLayout.Trailing
                }
            }
        }

        Rectangle {
            width: parent.width
            height: units.gu(2)
            color: theme.palette.normal.background
        }

        Rectangle {
            width: parent.width
            height: units.gu(2)
            color: theme.palette.normal.background
            Label {
                id: userInfo
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Create a new chat")
                font.bold: true
            }
        }

        Rectangle {
            width: parent.width
            height: units.gu(2)
            color: theme.palette.normal.background
        }

        Rectangle {
            width: parent.width
            height: searchField.height
            color: theme.palette.normal.background
            TextField {
                id: searchField
                objectName: "searchField"
                property var searchMatrixId: false
                property var upperCaseText: displayText.toUpperCase()
                property var tempElement: null
                z: 5
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: units.gu(2)
                    leftMargin: units.gu(2)
                }
                focus: true
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Search for example @username:server.abc")
                onDisplayTextChanged: {

                    if ( displayText.slice( 0,1 ) === "@" && displayText.length > 1 ) {
                        var input = displayText
                        if ( input.indexOf(":") === -1 ) {
                            input += ":" + settings.server
                        }
                        if ( tempElement !== null ) {
                            model.remove ( tempElement)
                            tempElement = null
                        }
                        if ( input.split(":").length > 2 || input.split("@").length > 2 || displayText.length < 2 ) return
                        model.append ( {
                            matrix_id: input,
                            medium: "matrix",
                            name: input,
                            address: input,
                            avatar_url: "",
                            last_active_ago: 0,
                            presence: "offline",
                            temp: true
                        })
                        tempElement = model.count - 1
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: units.gu(2)
            color: theme.palette.normal.background
        }

        Rectangle {
            width: parent.width
            height: 1
            color: UbuntuColors.ash
        }
    }



    ListView {
        id: chatListView
        width: parent.width
        height: parent.height - 2*header.height - contentColumn.height
        anchors.top: contentColumn.bottom
        delegate: ContactListItem {}
        model: ListModel { id: model }
        Button {
            anchors.centerIn: chatListView
            iconName: "contact-new"
            color: UbuntuColors.porcelain
            text: i18n.tr("Import from contacts")
            width: parent.width - units.gu(10)
            height: units.gu(5)
            visible: model.count === 0
            onClicked: contactImport.requestContact()
        }

        footer: SettingsListFooter {
            icon: newContactAction.iconName
            name: newContactAction.text
            iconWidth: units.gu(3)
            onClicked: {
                contactImport.requestContact()
                selectMode = false
            }
        }
    }

    ContactImport {
        id: contactImport
        newContactsFound: function () { update() }
    }

    Rectangle {
        z: 2
        width: parent.width
        anchors.bottom: parent.bottom
        height: header.height * 3
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00FFFFFF" }
            GradientStop { position: 1.0; color: settings.darkmode ? "#FF000000" : "#FFFFFFFF" }
        }
    }

    Button {
        z: 3
        id: button
        text: i18n.tr("Create chat")
        width: parent.width - units.gu(4)
        color: UbuntuColors.green
        anchors {
            bottom: parent.bottom
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }

        onClicked: {
            loadingScreen.visible = true
            var is_direct = inviteList.length === 1
            matrix.post( "/client/r0/createRoom", {
                invite: inviteList,
                is_direct: is_direct,
                preset: is_direct ? "trusted_private_chat" : "private_chat"
            }, function ( response ) {
                toast.show ( i18n.tr("Please notice that FluffyChat does only support transport encryption yet."))
                mainStack.toChat ( response.room_id )
            }, null, 2 )
        }
    }
}
