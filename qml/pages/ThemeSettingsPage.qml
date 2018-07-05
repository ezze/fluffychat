import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Theme')
    }

    MediaImport { id: backgroundImport }

    Connections {
        target: backgroundImport
        onMediaReceived: changeBackground ( mediaUrl )
    }

    function changeBackground ( mediaUrl ) {
        console.log( mediaUrl )
        settings.chatBackground = mediaUrl
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: root.width

            SettingsListSwitch {
                name: i18n.tr("Dark mode")
                icon: "display-brightness-max"
                onSwitching: function () { settings.darkmode = isChecked }
                isChecked: settings.darkmode
                isEnabled: true
            }

            ListItem {
                property var name: ""
                property var icon: "settings"
                onClicked: settings.chatBackground === undefined ? backgroundImport.requestMedia () : settings.chatBackground = undefined
                height: layout.height

                ListItemLayout {
                    id: layout
                    title.text: settings.chatBackground === undefined ? i18n.tr("Set chat background") : i18n.tr("Remove chat background")
                    Icon {
                        name: "image-x-generic-symbolic"
                        color: settings.mainColor
                        width: units.gu(4)
                        height: units.gu(4)
                        SlotsLayout.position: SlotsLayout.Leading
                    }
                    Icon {
                        width: units.gu(2)
                        height: units.gu(2)
                        SlotsLayout.position: SlotsLayout.Trailing
                        name: "edit-delete"
                        color: UbuntuColors.red
                        visible: settings.chatBackground !== undefined
                    }
                }
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
                text: i18n.tr("Choose a main color:")
                font.bold: true
            }

            SettingsListItem {
                name: i18n.tr("Purple")
                icon: "starred"
                iconColor: defaultMainColor
                onClicked: settings.mainColor = iconColor
            }

            SettingsListItem {
                name: i18n.tr("Blue")
                icon: "starred"
                iconColor: UbuntuColors.blue
                onClicked: settings.mainColor = iconColor
            }

            SettingsListItem {
                name: i18n.tr("Red")
                icon: "starred"
                iconColor: UbuntuColors.red
                onClicked: settings.mainColor = iconColor
            }

            SettingsListItem {
                name: i18n.tr("Orange")
                icon: "starred"
                iconColor: UbuntuColors.orange
                onClicked: settings.mainColor = iconColor
            }

            SettingsListItem {
                name: i18n.tr("Graphite")
                icon: "starred"
                iconColor: UbuntuColors.graphite
                onClicked: settings.mainColor = iconColor
            }

            SettingsListItem {
                name: i18n.tr("Green")
                icon: "starred"
                iconColor: UbuntuColors.green
                onClicked: settings.mainColor = iconColor
            }

        }
    }
}
