import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Edit chat picture")
        property var chatName
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("New chat picture")
            visible: platform === platforms.UBPORTS
            color: UbuntuColors.green
            onClicked: {
                var _matrix = matrix
                var _activeChat = activeChat
                var editFunction = function (responseText) {
                    _matrix.put ( "/client/r0/rooms/" + _activeChat + "/state/m.room.avatar", { url: JSON.parse(responseText).content_uri }, null, null, 2)
                }
                var uploadFunction = function (mediaUrl) {
                    _matrix.upload(mediaUrl, editFunction)
                }
                contentHub.importPicture(uploadFunction)
                PopupUtils.close(dialogue)
            }
        }

        Button {
            width: (parent.width - units.gu(1)) / 2
            text: i18n.tr("Remove picture")
            visible: hasAvatar
            color: UbuntuColors.red
            onClicked: {
                matrix.put ( "/client/r0/rooms/" + activeChat + "/state/m.room.avatar", { url: "" }, null, null, 2)
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
