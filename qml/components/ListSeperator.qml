import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var text
    height: layout.height
    ListItemLayout {
        id: layout
        title.text: text
        title.font.bold: true
    }
}
