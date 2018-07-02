import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Join group")

        Rectangle {
            height: icon.height
            Icon {
                id: icon
                width: parent.width / 2
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                name: "user-admin"
                color: settings.mainColor
            }
        }
        TextField {
            id: groupTextField
            placeholderText: i18n.tr("#groupname:" + settings.server)
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
                text: i18n.tr("Continue")
                enabled: groupTextField.displayText !== ""
                color: UbuntuColors.green
                onClicked: {
                    events.waitForSync ()
                    matrix.post( "/client/r0/join/" + encodeURIComponent(groupTextField.displayText), null, success_callback )
                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
