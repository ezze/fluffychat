import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Web 0.2
import "../components"

Page {
    anchors.fill: parent

    property var displayname
    property var hasAvatar: false

    Connections {
        target: events
        onNewEvent: updateAvatar ( type, chat_id, eventType, eventContent )
    }

    MediaImport { id: backgroundImport }

    Connections {
        target: backgroundImport
        onMediaReceived: changeBackground ( mediaUrl )
    }

    function changeBackground ( mediaUrl ) {
        settings.chatBackground = mediaUrl
    }

    function updateAvatar ( type, chat_id, eventType, eventContent ) {
        if ( type === "m.room.member" && eventContent.sender === settings.matrixid ) {
            storage.transaction ( "SELECT avatar_url, displayname FROM Users WHERE matrix_id='" + settings.matrixid + "'", function (rs) {
                if ( rs.rows.length > 0 ) {
                    var displayname = rs.rows[0].displayname !== "" ? rs.rows[0].displayname : settings.matrixid
                    avatarImage.name = displayname
                    avatarImage.mxc = rs.rows[0].avatar_url
                    hasAvatar = (rs.rows[0].avatar_url !== "" && rs.rows[0].avatar_url !== null)
                    header.title = i18n.tr('Settings for %1').arg( displayname )
                }
            })
        }
    }

    header: FcPageHeader {
        title: i18n.tr('Settings')
        flickable: scrollView.flickableItem

        trailingActionBar {
            actions: [
            Action {
                iconName: "share"
                text: i18n.tr("Share invite link")
                onTriggered: shareController.shareLink("https://matrix.to/#/%1".arg(settings.matrixid))
            },
            Action {
                iconName: "camera-app-symbolic"
                text: i18n.tr("Change profile picture")
                onTriggered: PopupUtils.open(changeAvatarDialog)
            },
            Action {
                iconName: "edit"
                text: i18n.tr("Edit displayname")
                onTriggered: PopupUtils.open(displaynameDialog)
            }
            ]
        }
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        contentItem: Column {
            width: mainStackWidth

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: "#00000000"
            }

            ProfileRow {
                id: profileRow
                matrixid: settings.matrixid
                displayname: displayname

                Component.onCompleted: {
                    storage.transaction ( "SELECT avatar_url, displayname FROM Users WHERE matrix_id='" + settings.matrixid + "'", function (rs) {
                        if ( rs.rows.length > 0 ) {
                            displayname = rs.rows[0].displayname !== "" ? rs.rows[0].displayname : settings.matrixid
                            profileRow.avatar_url = rs.rows[0].avatar_url
                        }
                    })
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.ash
            }



            SettingsListItem {
                name: i18n.tr("Change main color")
                icon: "preferences-desktop-wallpaper-symbolic"
                onClicked: PopupUtils.open(colorDialog)
            }

            ListItem {
                property var name: ""
                property var icon: "settings"
                onClicked: backgroundImport.requestMedia ()
                height: layout.height

                ListItemLayout {
                    id: layout
                    title.text: i18n.tr("Change background")
                    Icon {
                        name: "image-x-generic-symbolic"
                        width: units.gu(3)
                        height: units.gu(3)
                        SlotsLayout.position: SlotsLayout.Leading
                    }

                    Rectangle {
                        id: removeIcon
                        SlotsLayout.position: SlotsLayout.Trailing
                        width: units.gu(4)
                        height: width
                        visible: settings.chatBackground !== undefined
                        color: settings.darkmode ? Qt.hsla( 0, 0, 0.04, 1 ) : Qt.hsla( 0, 0, 0.96, 1 )
                        border.width: 1
                        border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
                        radius: width / 6
                        MouseArea {
                            anchors.fill: parent
                            visible: settings.chatBackground !== undefined
                            onClicked: {
                                settings.chatBackground = undefined
                                toast.show ( i18n.tr("Background removed") )
                            }
                        }
                        Icon {
                            width: units.gu(2)
                            height: units.gu(2)
                            anchors.centerIn: parent
                            name: "edit-delete"
                            color: UbuntuColors.red
                            visible: settings.chatBackground !== undefined
                        }
                    }
                }
            }

            SettingsListSwitch {
                name: i18n.tr("Dark mode")
                icon: "display-brightness-max"
                onSwitching: function () { settings.darkmode = isChecked }
                isChecked: settings.darkmode
            }

            SettingsListLink {
                name: i18n.tr("Notifications")
                icon: "notification"
                page: "NotificationSettingsPage"
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }

            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Chat settings:")
                font.bold: true
            }

            SettingsListSwitch {
                name: i18n.tr("Display 'I am typing' when typing")
                icon: "edit"
                onSwitching: function () { settings.sendTypingNotification = isChecked }
                isChecked: settings.sendTypingNotification
            }

            SettingsListSwitch {
                name: i18n.tr("Hide less important events")
                icon: "info"
                onSwitching: function () { settings.hideLessImportantEvents = isChecked }
                isChecked: settings.hideLessImportantEvents
            }

            SettingsListSwitch {
                name: i18n.tr("Autoload animated images")
                icon: "stock_image"
                onSwitching: function () { settings.autoloadGifs = isChecked }
                isChecked: settings.autoloadGifs
            }

            SettingsListLink {
                name: i18n.tr("Archived chats")
                icon: "inbox-all"
                page: "ArchivedChatsPage"
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }

            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Account settings:")
                font.bold: true
            }

            SettingsListLink {
                name: i18n.tr("Connected phone numbers")
                icon: "phone-symbolic"
                page: "PhoneSettingsPage"
            }

            SettingsListLink {
                name: i18n.tr("Connected email addresses")
                icon: "email"
                page: "EmailSettingsPage"
            }

            SettingsListLink {
                name: i18n.tr("Devices")
                icon: "phone-smartphone-symbolic"
                page: "DevicesSettingsPage"
            }

            SettingsListItem {
                name: i18n.tr("Change password")
                icon: "lock"
                onClicked: PopupUtils.open(passwordDialog)
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }

            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Check out:")
                font.bold: true
            }

            SettingsListItem {
                name: i18n.tr("Disable account")
                icon: "edit-delete"
                onClicked: PopupUtils.open(accountDialog)
            }

            SettingsListItem {
                name: i18n.tr("Log out")
                icon: "system-shutdown"
                onClicked: PopupUtils.open(logoutDialog)
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }

            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("More:")
                font.bold: true
            }

            SettingsListLink {
                name: i18n.tr("About FluffyChat")
                icon: "info"
                page: "InfoPage"
            }
        }
    }

    ChangeDisplaynameDialog { id: displaynameDialog }
    ChangeAvatarDialog { id: changeAvatarDialog }
    ChangePasswordDialog { id: passwordDialog }
    ColorDialog { id: colorDialog }
    DisableAccountDialog { id: accountDialog }
    LogoutDialog { id: logoutDialog }
}
