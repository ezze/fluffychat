import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Add new chat address")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        TextField {
            id: addressTextField
            placeholderText: i18n.tr("#chatname:%1").arg( settings.server )
            focus: true
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
                text: i18n.tr("Save")
                color: UbuntuColors.green
                enabled: addressTextField.displayText.indexOf("#") !== -1 && addressTextField.displayText.indexOf(":") !== -1
                onClicked: {
                    matrix.put("/client/r0/directory/room/" + encodeURIComponent(addressTextField.displayText), { "room_id": activeChat }, function () {
                        PopupUtils.close(dialogue)
                    }, function () {
                        dialogue.title = i18n.tr("Please try another address")
                    } )

                }
            }
        }
    }
}
