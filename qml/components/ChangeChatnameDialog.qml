import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Edit name and description")
        property var chatName
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }
        TextField {
            id: chatnameTextField
            placeholderText: i18n.tr("Enter a name for the chat")
            Component.onCompleted: {
                var res = storage.query ( "SELECT topic FROM Chats WHERE id='%1'".arg(activeChat))
                if ( res.rows.length > 0 ) {
                    chatnameTextField.text = chatName = res.rows[0].topic
                }
            }
        }

        TextArea {
            id: descriptionTextField
            placeholderText: i18n.tr("Enter a description for the chat")
            text: description
            height: chatnameTextField.height *3
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
                onClicked: {

                    // Change the name if the user has changed it
                    if ( chatnameTextField.displayText !== chatName ) {
                        var messageID = Math.floor((Math.random() * 1000000) + 1)
                        matrix.put( "/client/r0/rooms/%1/send/m.room.name/%2".arg(activeChat).arg(messageID),
                        {
                            name: chatnameTextField.displayText
                        } )
                    }

                    // Change the description if the user has changed it
                    if ( descriptionTextField.displayText !== description ) {
                        var messageID2 = Math.floor((Math.random() * 1000000) + 1)
                        matrix.put( "/client/r0/rooms/%1/send/m.room.topic/%2".arg(activeChat).arg(messageID2),
                        {
                            topic: descriptionTextField.displayText
                        } )
                    }

                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
