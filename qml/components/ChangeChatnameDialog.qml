import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/ChangeChatNameDialogActions.js" as ItemActions

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Chat settings and details")
        property var chatName
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }
        Button {
            visible: canChangeAvatar
            text: i18n.tr("Change chat avatar")
            color: mainLayout.mainColor
            onClicked: PopupUtils.open(changeChatAvatarDialog)
        }
        TextField {
            id: chatnameTextField
            placeholderText: i18n.tr("Enter a name for the chat")
            readOnly: !canChangeName
            text: storage.query ( "SELECT topic FROM Chats WHERE id='%1'".arg(activeChat)).rows[0].topic
        }

        TextArea {
            id: descriptionTextField
            placeholderText: i18n.tr("Enter a description for the chat")
            text: description
            height: chatnameTextField.height *3
            readOnly: !canChangeName
        }

        Row {
            width: parent.width
            spacing: units.gu(1)
            visible: canChangeName
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Save")
                color: UbuntuColors.green
                onClicked: ItemActions.save ( chatnameTextField, descriptionTextField, dialogue )
            }
        }

        Button {
            visible: !canChangeName
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
