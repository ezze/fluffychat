import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Target details")
        Rectangle {
            height: icon.height
            Icon {
                id: icon
                width: parent.width / 2
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                name: "info"
                color: defaultMainColor
            }
        }
        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>Device name</b>: %2".arg(currentTarget.device_display_name) )
        }
        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>App</b>: %2".arg(currentTarget.app_display_name) )
        }
        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>Kind</b>: %2".arg(currentTarget.kind) )
        }
        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>Language</b>: %2".arg(currentTarget.lang) )
        }
        Label {
            wrapMode: Text.Wrap
            text: i18n.tr("<b>Gateway</b>: %2".arg(currentTarget.data.url) )
        }
        Row {
            width: parent.width
            spacing: units.gu(1)
            Button {
                width: parent.width
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }
}
