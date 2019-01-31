import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    id: listItem
    property var name: ""
    property var icon: "settings"
    property var rightIcon: ""
    property var iconColor: settings.mainColor
    property var iconWidth: units.gu(6)
    height: layout.height
    color: settings.darkmode ? "#202020" : "white"

    selectMode: false

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainFontColor

        UbuntuShape {
            SlotsLayout.position: SlotsLayout.Leading
            width: iconWidth
            height: listItem.visible ? width : 0
            aspect: UbuntuShape.Flat
            backgroundColor: settings.darkmode ? Qt.hsla( 0, 0, 0.04, 1 ) : Qt.hsla( 0, 0, 0.96, 1 )
            relativeRadius: 0.75
            Icon {
                width: iconWidth / 2
                height: width
                anchors.centerIn: parent
                name: icon
                color: mainFontColor
            }
        }


        Icon {
            name: "toolkit_chevron-ltr_4gu"
            width: iconWidth / 2
            height: width
            SlotsLayout.position: SlotsLayout.Trailing
        }

    }
}
