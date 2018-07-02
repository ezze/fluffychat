import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Logout")

        Rectangle {
            height: icon.height
            Icon {
                id: icon
                width: parent.width / 2
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                name: "system-shutdown"
                color: settings.mainColor
            }
        }
        Label {
            text: i18n.tr("Are you sure, that you want to logout?")
            color: UbuntuColors.red
            width: parent.width
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
                text: i18n.tr("Logout")
                color: UbuntuColors.red
                onClicked: matrix.logout ()
            }
        }
    }
}
