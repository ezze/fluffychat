import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/AddEmailDialogActions.js" as ItemActions

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Connect new email address")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }
        TextField {
            id: addressTextField
            placeholderText: i18n.tr("youremail@example.edu")
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
                text: i18n.tr("Connect")
                color: UbuntuColors.green
                enabled: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test( addressTextField.displayText )
                onClicked: ItemActions.add ( addressTextField.displayText, dialogue )
            }
        }
    }
}
