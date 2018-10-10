import QtQuick 2.4
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

    function updateAvatar ( type, chat_id, eventType, eventContent ) {
        if ( type === "m.room.member" && eventContent.sender === matrix.matrixid ) {
            storage.transaction ( "SELECT avatar_url, displayname FROM Users WHERE matrix_id='" + matrix.matrixid + "'", function (rs) {
                if ( rs.rows.length > 0 ) {
                    var displayname = rs.rows[0].displayname !== "" ? rs.rows[0].displayname : matrix.matrixid
                    avatarImage.name = displayname
                    avatarImage.mxc = rs.rows[0].avatar_url
                    header.title = i18n.tr('Settings for %1').arg( displayname )
                }
            })
        }
    }

    header: FcPageHeader {
        title: i18n.tr('Settings for %1').arg(matrix.matrixid)

        trailingActionBar {
            numberOfSlots: 1
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
                name: matrix.matrixid
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                mxc: ""
                Component.onCompleted: {
                    storage.transaction ( "SELECT avatar_url, displayname FROM Users WHERE matrix_id='" + matrix.matrixid + "'", function (rs) {
                        if ( rs.rows.length > 0 ) {
                            var displayname = rs.rows[0].displayname !== "" ? rs.rows[0].displayname : matrix.matrixid
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
                            onTriggered: matrix.put ( "/client/r0/profile/" + matrix.matrixid + "/avatar_url", { avatar_url: "" }, function () {
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
                url: "../components/ChangeUserAvatar.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&matrixID=" + encodeURIComponent(matrix.matrixid)
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
                matrix_id: matrix.matrixid
            }

            SettingsListLink {
                name: i18n.tr("Theme")
                icon: "image-x-generic-symbolic"
                page: "ThemeSettingsPage"
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
                Component.onCompleted: isChecked = settings.sendTypingNotification
            }

            SettingsListSwitch {
                name: i18n.tr("Show member change events")
                icon: "contact-group"
                onSwitching: function () { settings.showMemberChangeEvents = isChecked }
                Component.onCompleted: isChecked = settings.showMemberChangeEvents
            }

            SettingsListSwitch {
                name: i18n.tr("Hide less important events")
                icon: "info"
                onSwitching: function () { settings.hideLessImportantEvents = isChecked }
                Component.onCompleted: isChecked = settings.hideLessImportantEvents
            }

            SettingsListSwitch {
                name: i18n.tr("Autoload animated images")
                icon: "stock_image"
                onSwitching: function () { settings.autoloadGifs = isChecked }
                Component.onCompleted: isChecked = settings.autoloadGifs
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
    DisableAccountDialog { id: accountDialog }
    LogoutDialog { id: logoutDialog }
}
