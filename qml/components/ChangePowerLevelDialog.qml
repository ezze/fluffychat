import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: powerLevelDescription
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        Column {
            SettingsListItem {
                name: i18n.tr("Owners")
                icon: "view-collapse"
                onClicked: {
                    var data = {}
                    if ( activePowerLevel.indexOf("m.room") !== -1 ) {
                        data["events"] = {}
                        data["events"][activePowerLevel] = 100
                    }
                    else data[activePowerLevel] = 100
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Guards")
                icon: "view-collapse"
                onClicked: {
                    var data = {}
                    if ( activePowerLevel.indexOf("m.room") !== -1 ) {
                        data["events"] = {}
                        data["events"][activePowerLevel] = 50
                    }
                    else data[activePowerLevel] = 50
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
                    PopupUtils.close(dialogue)
                }
            }
            SettingsListItem {
                name: i18n.tr("Members")
                icon: "view-collapse"
                onClicked: {
                    var data = {}
                    if ( activePowerLevel.indexOf("m.room") !== -1 ) {
                        data["events"] = {}
                        data["events"][activePowerLevel] = 0
                    }
                    else data[activePowerLevel] = 0
                    matrix.put("/client/r0/rooms/" + activeChat + "/state/m.room.power_levels/", data )
                    PopupUtils.close(dialogue)
                }
            }
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
