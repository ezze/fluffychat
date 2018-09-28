import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Web 0.2
import "../components"

Page {
    anchors.fill: parent

    property var membership: "unknown"
    property var max: 20
    property var position: 0
    property var blocked: false
    property var newContactMatrixID
    property var description: ""

    property var activeUserPower
    property var activeUserMembership

    // User permission
    property var power
    property var canChangeName
    property var canKick
    property var canBan
    property var canInvite
    property var canChangePermissions
    property var canChangeAvatar

    property var memberCount: 0

    // To disable the background image on this page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    Connections {
        target: events
        onNewEvent: update ( type, chat_id, eventType, eventContent )
    }

    function init () {

        // Get the member status of the user himself
        storage.transaction ( "SELECT description, membership, power_event_name, power_kick, power_ban, power_invite, power_event_power_levels FROM Chats WHERE id='" + activeChat + "'", function (res) {

            description = res.rows[0].description
            storage.transaction ( "SELECT * FROM Memberships WHERE chat_id='" + activeChat + "' AND matrix_id='" + matrix.matrixid + "'", function (res2) {
                membership = res2.rows[0].membership
                power = res2.rows[0].power_level
                canChangeName = power >= res.rows[0].power_event_name
                canKick = power >= res.rows[0].power_kick
                canBan = power >= res.rows[0].power_ban
                canInvite = power >= res.rows[0].power_invite
                canChangeAvatar = power >= (res.rows[0].power_event_avatar || 0)
                canChangePermissions = power >= res.rows[0].power_event_power_levels
            })
        })

        // Get the chat avatar
        roomnames.getAvatarUrl ( activeChat, function ( avatar_url ) { avatarImage.mxc = avatar_url } )

        // Request the full memberlist, from the database
        model.clear()
        memberCount = 0
        storage.transaction ( "SELECT Users.matrix_id, Users.displayname, Users.avatar_url, Memberships.membership, Memberships.power_level " +
        " FROM Users, Memberships WHERE Memberships.chat_id='" + activeChat + "' " +
        " AND Users.matrix_id=Memberships.matrix_id " +
        " ORDER BY Memberships.membership", function (response) {
            for ( var i = 0; i < response.rows.length; i++ ) {
                var member = response.rows[ i ]
                if ( member.membership === "join" ) memberCount++
                model.append({
                    name: member.displayname || usernames.transformFromId( member.matrix_id ),
                    matrixid: member.matrix_id,
                    membership: member.membership,
                    avatar_url: member.avatar_url,
                    userPower: member.power_level
                })
            }
        })
    }


    function update ( type, chat_id, eventType, eventContent ) {
        if ( activeChat !== chat_id ) return
        var matchTypes = [ "m.room.member", "m.room.topic", "m.room.power_levels", "m.room.avatar", "m.room.name" ]
        if ( matchTypes.indexOf( type ) !== -1 ) init ()
    }

    function getDisplayMemberStatus ( membership ) {
        if ( membership === "join" ) return i18n.tr("Member")
        else if ( membership === "invite" ) return i18n.tr("Was invited")
        else if ( membership === "leave" ) return i18n.tr("Has left the chat")
        else if ( membership === "knock" ) return i18n.tr("Has knocked")
        else if ( membership === "ban" ) return i18n.tr("Was banned from the chat")
        else return i18n.tr("Unknown")
    }

    function startChat_callback ( response ) {
        activeChat = response.room_id
        if ( mainStack.depth === 1 ) bottomEdge.collapse()
        else mainStack.pop ()
        mainStack.push (Qt.resolvedUrl("./ChatPage.qml"))
    }


    Component.onCompleted: init ()

    ChangeChatnameDialog { id: changeChatnameDialog }

    LeaveChatDialog { id: leaveChatDialog }

    header: FcPageHeader {
        id: header
        title: activeChatDisplayName

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                visible: canChangeName
                iconName: "compose"
                text: i18n.tr("Edit chat name")
                onTriggered: PopupUtils.open(changeChatnameDialog)
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
            width: mainStackWidth
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }
            Avatar {  // Useravatar
                id: avatarImage
                name: activeChatDisplayName
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                mxc: ""
                onClickFunction: function () {
                    var hasAvatar = avatarImage.mxc !== "" && avatarImage.mxc !== null
                    if ( canChangeAvatar && hasAvatar ) contextualAvatarActions.show()
                    else if ( hasAvatar ) imageViewer.show ( mxc )
                }
                ActionSelectionPopover {
                    id: contextualAvatarActions
                    z: 10
                    actions: ActionList {
                        Action {
                            text: i18n.tr("Show image")
                            onTriggered: imageViewer.show ( avatarImage.mxc )
                        }
                        Action {
                            text: i18n.tr("Delete Avatar")
                            onTriggered: matrix.put ( "/client/r0/rooms/" + activeChat + "/state/m.room.avatar", { url: "" })
                        }
                    }
                }
            }
            Component {
                id: pickerComponent
                PickerDialog {}
            }
            WebView {
                id: uploader
                url: "../components/ChangeChatAvatar.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&activeChat=" + encodeURIComponent(activeChat)
                width: units.gu(6)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                preferences.allowFileAccessFromFileUrls: true
                preferences.allowUniversalAccessFromFileUrls: true
                filePicker: pickerComponent
                visible: canChangeAvatar
                alertDialog: Dialog {
                    title: i18n.tr("Error")
                    text: model.message
                    parent: QuickUtils.rootItem(this)
                    Button {
                        text: i18n.tr("OK")
                        onClicked: model.accept()
                    }
                    Component.onCompleted: show()
                }
            }
            Label {
                visible: description !== ""
                width: parent.width - units.gu(4)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                wrapMode: Text.Wrap
                text: description
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
                visible: description !== ""
            }
            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Chat Settings:")
                font.bold: true
            }
            Rectangle {
                width: parent.width
                height: settingsColumn.height
                color: theme.palette.normal.background
                Column {
                    id: settingsColumn
                    width: parent.width
                    SettingsListLink {
                        visible: canInvite
                        name: i18n.tr("Invite friend")
                        icon: "contact-new"
                        page: "InvitePage"
                        onClicked: model.clear()
                    }
                    SettingsListLink {
                        name: i18n.tr("Notifications")
                        icon: "notification"
                        page: "NotificationChatSettingsPage"
                        onClicked: model.clear()
                    }
                    SettingsListLink {
                        name: i18n.tr("Security & Privacy")
                        icon: "system-lock-screen"
                        page: "ChatPrivacySettingsPage"
                        onClicked: model.clear()
                    }
                    SettingsListLink {
                        name: i18n.tr("Chat addresses")
                        icon: "bookmark"
                        page: "ChatAliasSettingsPage"
                        onClicked: model.clear()
                    }
                    SettingsListItem {
                        name: i18n.tr("Leave Chat")
                        icon: "delete"
                        onClicked: PopupUtils.open(leaveChatDialog)
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
                    text: memberList.count > 0 ? i18n.tr("Users in this chat (%1):").arg(memberCount) : i18n.tr("Press button to reload users...")
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
                height: searchField.height + units.gu(2)
                color: theme.palette.normal.background
                TextField {
                    id: searchField
                    objectName: "searchField"
                    property var upperCaseText: displayText.toUpperCase()
                    anchors {
                        left: parent.left
                        right: parent.right
                        rightMargin: units.gu(2)
                        leftMargin: units.gu(2)
                    }
                    inputMethodHints: Qt.ImhNoPredictiveText
                    placeholderText: i18n.tr("Search...")
                    onActiveFocusChanged: if ( activeFocus ) scrollView.flickableItem.contentY = scrollView.flickableItem.contentHeight - scrollView.height
                }
            }
            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.ash
            }

            ListView {
                id: memberList
                width: parent.width
                height: root.height / 1.5
                delegate: MemberListItem { }
                model: ListModel { id: model }
                z: -1

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: height
                    text: i18n.tr("Reload")
                    color: UbuntuColors.green
                    onClicked: init()
                    visible: model.count === 0
                }
            }
        }
    }

}
