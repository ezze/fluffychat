import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Web 0.2

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Edit profile picture")
        property var chatName
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: settings.mainColor
        }

        Item {

            height: uploader.height

            Component {
                id: pickerComponent
                PickerDialog {}
            }
            WebView {
                id: uploader
                url: "../components/ChangeUserAvatar.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&matrixID=" + encodeURIComponent(settings.matrixid)
                width: units.gu(6)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                preferences.allowFileAccessFromFileUrls: true
                preferences.allowUniversalAccessFromFileUrls: true
                filePicker: pickerComponent
                alertDialog: Dialog {
                    title: i18n.tr("Error")
                    text: model.message
                    parent: QuickUtils.rootItem(this)
                    Button {
                        text: i18n.tr("OK")
                        onClicked: model.accept()
                    }
                    Component.onCompleted: show()
                }
            }
        }


        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Remove picture")
            visible: hasAvatar
            color: UbuntuColors.red
            onClicked: {
                matrix.put ( "/client/r0/profile/" + settings.matrixid + "/avatar_url", { avatar_url: "" }, function () {
                    profileRow.avatar_url = ""
                }, null, 2)
                PopupUtils.close(dialogue)
            }
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Close")
            onClicked: PopupUtils.close(dialogue)
        }
    }
}
