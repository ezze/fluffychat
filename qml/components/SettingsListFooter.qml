import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var name: ""
    property var icon: "settings"
    property var rightIcon: ""
    property var iconColor: settings.mainColor
    property var iconWidth: units.gu(6)
    height: layout.height

    selectMode: false

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainFontColor

        Rectangle {
            SlotsLayout.position: SlotsLayout.Leading
            width: iconWidth
            height: width
            color: settings.darkmode ? Qt.hsla( 0, 0, 0.04, 1 ) : Qt.hsla( 0, 0, 0.96, 1 )
            border.width: 1
            border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
            radius: width / 6
            Icon {
                width: iconWidth / 2
                height: width
                anchors.centerIn: parent
                name: icon
                color: iconColor
            }
        }


        Icon {
            name: "toolkit_chevron-ltr_4gu"
            width: units.gu(3)
            height: units.gu(3)
            SlotsLayout.position: SlotsLayout.Trailing
        }

    }
}
