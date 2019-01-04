import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Component {
    id: slide

    property var title: "Title"
    property var text: "Text"
    property var imagePath: "../../assets/sticker09.jpg"

    Item {
        id: slideContainer

        Image {
            id: smileImage
            anchors {
                top: parent.top
                topMargin: units.gu(4)
                horizontalCenter: parent.horizontalCenter
            }
            height: (parent.height - introductionText.height - finalMessage.contentHeight - 4.5*units.gu(4))
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(imagePath)
            asynchronous: true
        }

        Label {
            id: introductionText
            anchors {
                bottom: bodyText.top
                bottomMargin: units.gu(4)
            }
            elide: Text.ElideRight
            fontSize: "x-large"
            horizontalAlignment: Text.AlignHLeft
            maximumLineCount: 2
            text: title
            width: units.gu(36)
            wrapMode: Text.WordWrap
        }

        Label {
            id: bodyText
            anchors {
                bottom: parent.bottom
                bottomMargin: units.gu(10)
            }
            fontSize: "large"
            height: contentHeight
            horizontalAlignment: Text.AlignHLeft
            text: text
            width: units.gu(36)
            wrapMode: Text.WordWrap
        }
    }
}
