import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    id: page

    header: StyledPageHeader {
        title: ""
        StyleHints {
            dividerColor: "#00000000"
            backgroundColor: "#00000000"
        }
    }


    Icon {
        source: "../../assets/chat.svg"
        color: settings.mainColor
        anchors.centerIn: parent
        width: parent.width
        height: width * ( 1052 / 744 )
        opacity: 0.2
        z: 0
    }

}
