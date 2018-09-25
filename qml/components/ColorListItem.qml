import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var name: ""
    property var value: ""
    property var icon: "toolkit_arrow-right"
    property var iconColor: settings.mainColor
    height: layout.height

    ListItemLayout {
        id: layout
        title.text: name
        subtitle.text: value
        Icon {
            name: icon
            color: iconColor
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
        }

        Icon {
            SlotsLayout.position: SlotsLayout.Trailing
            name: "tick"
            visible: settings.mainColor === iconColor
            width: units.gu(2)
            height: width
        }
    }
}
