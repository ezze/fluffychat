import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Leave chat")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Are you sure you want to leave the chat?")
            wrapMode: Text.Wrap
        }
        Row {
            width: parent.width
            spacing: units.gu(1)
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Leave")
                color: UbuntuColors.red
                onClicked: {
                    PopupUtils.close(dialogue)
                    matrix.post("/client/r0/rooms/" + activeChat + "/leave", null, function () {
                        events.waitForSync ()
                        mainStack.pop()
                    })
                }
            }
        }
    }
}
