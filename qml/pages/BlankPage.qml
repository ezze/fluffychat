import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    id: page

    header: FcPageHeader {
        title: i18n.tr('Welcome')
    }


    Rectangle {
        visible: settings.chatBackground === undefined
        anchors.fill: parent
        color: UbuntuColors.jet
        z: 0
    }

    Icon {
        visible: settings.chatBackground === undefined
        source: "../../assets/chat.svg"
        anchors.centerIn: parent
        width: parent.width / 1.25
        height: width
        opacity: 0.15
        z: 0
    }

}
