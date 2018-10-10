import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var matrix_id
    id: usernameListItem
    height: usernameListItemLayout.height
    color: Qt.rgba(0,0,0,0)
    ListItemLayout {
        id: usernameListItemLayout
        title.text: i18n.tr("Full username:")
        subtitle.text: matrix_id
    }
    Icon {
        name: "share"
        width: units.gu(2)
        height: width
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: (parent.height - width) / 2
    }
    onClicked: shareController.shareLink ( "fluffychat://%1".arg(matrix_id) )
}
