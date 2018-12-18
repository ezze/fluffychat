import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var name: ""
    property var icon: "settings"
    property var iconColor: settings.mainColor
    property var page
    height: layout.height
    onClicked: mainStack.push(Qt.resolvedUrl("../pages/%1.qml".arg(page)))

    ListItemLayout {
        id: layout
        title.text: name
        title.color: settings.darkmode ? "white" : "black"
        Icon {
            name: icon
            color: iconColor
            width: units.gu(4)
            height: units.gu(4)
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
