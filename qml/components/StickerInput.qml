import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Web 0.2
import "../components"

Rectangle {
    id: stickerInput
    visible: false
    width: parent.width + 2
    property var desiredHeight: 3 * header.height
    height: desiredHeight
    border.width: 1
    border.color: UbuntuColors.silk
    color: theme.palette.normal.background
    anchors.horizontalCenter: parent.horizontalCenter

    ActionSelectionPopover {
        id: deleteActions
        property var contextElem
        z: 10
        actions: ActionList {
            Action {
                text: i18n.tr("Delete sticker")
                onTriggered: {
                    var url = deleteActions.contextElem.url
                    storage.transaction ( "DELETE FROM Media WHERE url='" + url + "'")
                    for ( var i = 0; i < stickerModel.count; i++ ) {
                        if ( stickerModel.get(i).mediaElem.url === url ) {
                            stickerModel.remove(i)
                            break
                        }
                    }
                }
            }
        }
    }

    function show() {
        messageTextField.focus = false
        visible = true
        storage.transaction ("SELECT * FROM Media", function ( res ) {
            stickerModel.clear()
            for ( var i = res.rows.length-1; i >= 0; i-- ) {
                stickerModel.append( { mediaElem: res.rows[i] } )
            }
        })
    }

    function hide() { visible = false }

    ListView {
        id: grid
        anchors.fill: parent
        orientation: ListView.Horizontal
        delegate: Rectangle {
            id: delegate
            width: grid.height
            height: grid.height
            AnimatedImage {
                id: image
                anchors.fill: delegate
                width: height * ( sourceSize.height / sourceSize.width )
                height: stickerInput.desiredHeight
                property var mediaElement: mediaElem
                source: {
                    ( (settings.autoloadGifs && mediaElem.mimetype === "image/gif") || mediaElem.thumbnail_url === "") ?
                    media.getLinkFromMxc ( mediaElem.url ) :
                    media.getThumbnailLinkFromMxc ( mediaElem.thumbnail_url, Math.round (height), Math.round (height) )
                }
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                anchors.fill: image
                onClicked: {
                    stickerInput.hide ()
                    send ( image.mediaElement )
                }
                onPressAndHold: {
                    deleteActions.contextElem = image.mediaElement
                    deleteActions.show()
                }
            }
        }
        header: WebView {
            id: uploader
            url: "../components/upload.html?token=" + encodeURIComponent(settings.token) + "&domain=" + encodeURIComponent(settings.server) + "&activeChat=" + encodeURIComponent(activeChat)
            width: stickerInput.desiredHeight
            height: width
            anchors.margins: stickerInput.desiredHeight / 2
            anchors.verticalCenter: parent.verticalCenter
            preferences.allowFileAccessFromFileUrls: true
            preferences.allowUniversalAccessFromFileUrls: true
            filePicker: pickerComponent
            visible: stickerInput.visible
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
        model: ListModel { id: stickerModel }
    }
}
