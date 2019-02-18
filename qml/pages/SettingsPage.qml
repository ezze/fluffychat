import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    id: settingsPage
    anchors.fill: parent

    property var displayname
    property var hasAvatar: false

    Connections {
        target: matrix
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
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        contentItem: Column {
            width: settingsPage.width

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: "#00000000"
            }

            Row {
                id: profileRow
                width: parent.width
                height: parent.width / 2
                spacing: units.gu(2)

                Component.onCompleted: {
                    storage.transaction ( "SELECT avatar_url, displayname FROM Users WHERE matrix_id='" + settings.matrixid + "'", function (rs) {
                        if ( rs.rows.length > 0 ) {
                            displayname = rs.rows[0].displayname !== "" ? rs.rows[0].displayname : settings.matrixid
                            avatarImage.mxc = rs.rows[0].avatar_url
                        }
                    })
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: "#00000000"
                }

                Avatar {  // Useravatar
                    id: avatarImage
                    name: settings.matrixid
                    height: parent.height - units.gu(3)
                    width: height
                    mxc: avatar_url
                    onClickFunction: function () {
                        imageViewer.show ( mxc )
                    }
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: parent.width / 2
                        opacity: 0.75
                        color: "#000000"
                        iconName: "camera-app-symbolic"
                        onClicked: PopupUtils.open(changeAvatarDialog)
                    }
                }

                Column {
                    width: parent.height - units.gu(3)
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: i18n.tr("Username:")
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.bold: true
                    }
                    Label {
                        text: settings.matrixid
                        width: parent.width
                        wrapMode: Text.Wrap
                    }
                    Label {
                        text: " "
                        width: parent.width
                    }
                    Label {
                        text: i18n.tr("Displayname:")
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.bold: true
                    }
                    Label {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: displayname
                    }
                    Label {
                        text: " "
                        width: parent.width
                    }
                    Button {
                        text: i18n.tr("Edit")
                        onClicked: PopupUtils.open(displaynameDialog)
                    }
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
                page: "NotificationTargetSettingsPage"
                sourcePage: settingsPage
            }

            ListSeperator {
                text: i18n.tr("Chat settings:")
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
                sourcePage: settingsPage
            }

            ListSeperator {
                text: i18n.tr("Account settings:")
            }

            SettingsListLink {
                name: i18n.tr("Connected phone numbers")
                icon: "phone-symbolic"
                page: "PhoneSettingsPage"
                sourcePage: settingsPage
            }

            SettingsListLink {
                name: i18n.tr("Connected email addresses")
                icon: "email"
                page: "EmailSettingsPage"
                sourcePage: settingsPage
            }

            SettingsListLink {
                name: i18n.tr("Devices")
                icon: "phone-smartphone-symbolic"
                page: "DevicesSettingsPage"
                sourcePage: settingsPage
            }

            SettingsListItem {
                name: i18n.tr("Change password")
                icon: "lock"
                onClicked: PopupUtils.open(passwordDialog)
            }

            ListSeperator {
                text: i18n.tr("Check out:")
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

            ListSeperator {
                text: i18n.tr("More:")
            }

            SettingsListLink {
                name: i18n.tr("About FluffyChat")
                icon: "info"
                page: "InfoPage"
                sourcePage: settingsPage
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
