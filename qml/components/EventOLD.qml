import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Rectangle {
    property var event
    width: root.width
    height: bubble.height + units.gu(1)
    color: "transparent"

    function update () {
        eventLabel.text = displayEvents.getDisplay ( event ) + " <font color='" + UbuntuColors.silk + "'>" + stamp.getChatTime ( event.origin_server_ts ) + "</font>"
    }

    Rectangle {
        id: bubble
        z: 2
        anchors.centerIn: parent
        border.width: 1
        border.color: theme.palette.normal.position
        color: theme.palette.normal.background
        radius: units.gu(2)
        height: eventLabel.height + units.gu(2)
        width: eventLabel.width + units.gu(2)
        opacity: 0.75

        Label {
            id: eventLabel
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: units.gu(1)
            Component.onCompleted: {
                var maxWidth = root.width - units.gu(4)
                if ( width > maxWidth ) width = maxWidth
                var urlRegex = /(https?:\/\/[^\s]+)/g;
                text = text.replace(urlRegex, function(url) {
                    return '<a href="%1"><font color="black">%1</font></a>'.arg(url)
                })
            }
            wrapMode: Text.Wrap
            text: displayEvents.getDisplay ( event ) + " <font color='" + UbuntuColors.silk + "'>" + stamp.getChatTime ( event.origin_server_ts ) + "</font>"
            textSize: Label.XSmall
            //font.italic: true
        }
    }
}
