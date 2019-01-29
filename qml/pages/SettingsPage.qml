import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Web 0.2
import "../components"

Page {
    anchors.fill: parent

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
                    header.title = i18n.tr('Settings for %1').arg( displayname )
                }
            })
        }
    }

    header: FcPageHeader {
        title: i18n.tr('Settings for %1').arg(settings.matrixid)
        flickable: scrollView.flickableItem

        trailingActionBar {
            actions: [
            Action {
                iconName: "compose"
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

            Avatar {  // Useravatar
                id: avatarImage
                name: settings.matrixid
                width: parent.width
                height: width * 10/16
                relativeRadius: 0
                anchors.horizontalCenter: parent.horizontalCenter
                mxc: ""
                Component.onCompleted: {
                    storage.transaction ( "SELECT avatar_url, displayname FROM Users WHERE matrix_id='" + settings.matrixid + "'", function (rs) {
                        if ( rs.rows.length > 0 ) {
                            var displayname = rs.rows[0].displayname !== "" ? rs.rows[0].displayname : settings.matrixid
                            avatarImage.name = displayname
                            avatarImage.mxc = rs.rows[0].avatar_url
                            header.title = i18n.tr('Settings for %1').arg( displayname )
                        }
                    })
                }
                onClickFunction: function () {
                    var hasAvatar = avatarImage.mxc !== "" && avatarImage.mxc !== null
                    if ( hasAvatar ) contextualAvatarActions.show()
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
                            onTriggered: matrix.put ( "/client/r0/profile/" + settings.matrixid + "/avatar_url", { avatar_url: "" }, function () {
                                avatarImage.mxc = ""
                            })
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
                url: "../components/ChangeUserAvatar.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&matrixID=" + encodeURIComponent(settings.matrixid)
                width: units.gu(6)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                preferences.allowFileAccessFromFileUrls: true
                preferences.allowUniversalAccessFromFileUrls: true
                filePicker: pickerComponent
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

            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.ash
            }

            UsernameListItem {
                matrix_id: settings.matrixid
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
    ChangePasswordDialog { id: passwordDialog }
    ColorDialog { id: colorDialog }
    DisableAccountDialog { id: accountDialog }
    LogoutDialog { id: logoutDialog }
}
