import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Invite a friend")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }
        TextField {
            id: matrixidTextField
            focus: true
            placeholderText: i18n.tr("@yourfriend:%1").arg(defaultDomain)
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
                text: i18n.tr("Invite")
                color: UbuntuColors.green
                onClicked: {
                    console.log( matrixidTextField.displayText)
                    matrix.post ( "/client/r0/rooms/%1/invite".arg(activeChat),
                    { user_id: matrixidTextField.displayText} )
                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
