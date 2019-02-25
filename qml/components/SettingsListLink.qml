import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var name: ""
    property var icon: "settings"
    property var iconColor: mainLayout.mainColor
    property var page
    property var sourcePage: mainLayout.primaryPage
    property var iconWidth: units.gu(3)
    height: layout.height
    onClicked: mainLayout.addPageToNextColumn ( sourcePage, Qt.resolvedUrl("../pages/%1.qml".arg(page)) )

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainLayout.darkmode ? "white" : "black"
        Icon {
            name: icon
            width: iconWidth
            height: iconWidth
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
