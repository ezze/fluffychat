import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/StartChatDialog.js" as StartChatDialog

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Add new contact")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }
        TextField {
            id: matrixidTextField
            placeholderText: i18n.tr("Enter the full @username")
        }
        Button {
            text: i18n.tr("Start private chat")
            color: UbuntuColors.green
            onClicked: {
                StartChatDialog.startChat ( dialogue, matrixidTextField.text )
                bottomEdge.collapse ()
            }
        }
        Label {
            text: i18n.tr("Your username is: %1").arg(matrix.matrixid)
            textSize: Label.Small
        }
        Rectangle {
            color: "transparent"
            height: orLabel.height
            width: parent.width
            visible: platform === platforms.UBPORTS

            Rectangle {
                height: units.gu(0.2)
                color: mainLayout.mainColor
                anchors.left: parent.left
                anchors.right: orLabel.left
                anchors.rightMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
            }
            Label {
                id: orLabel
                text: i18n.tr("Or")
                textSize: Label.Small
                anchors.centerIn: parent
            }
            Rectangle {
                height: units.gu(0.2)
                color: mainLayout.mainColor
                anchors.right: parent.right
                anchors.left: orLabel.right
                anchors.leftMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                visible: platform === platforms.UBPORTS
            }
        }
        Button {
            text: i18n.tr("Import from addressbook")
            color: mainLayout.mainColor
            visible: platform === platforms.UBPORTS
            onClicked: {
                contactImport.requestContact()
                PopupUtils.close(dialogue)
            }
        }
        Button {
            text: i18n.tr("Cancel")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
