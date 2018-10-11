import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Change your display name")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: defaultMainColor
        }
        TextField {
            id: displaynameTextField
            placeholderText: i18n.tr("Enter your new nickname")
            focus: true
            Component.onCompleted: {
                storage.transaction ( "SELECT displayname FROM Users WHERE matrix_id='%1'".arg(matrix.matrixid), function ( res ) {
                    if ( res.rows.length > 0 ) {
                        displaynameTextField.text = res.rows[0].displayname
                    }
                })
            }
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
                    matrix.put ( "/client/r0/profile/%1/displayname".arg(matrix.matrixid),
                    { displayname: displaynameTextField.displayText} )
                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
