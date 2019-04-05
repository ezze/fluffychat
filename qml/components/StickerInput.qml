import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames

Rectangle {
    id: stickerInput
    opacity: 0
    width: parent.width + 2
    property var desiredHeight: 3 * header.height
    visible: false
    height: desiredHeight
    border.width: 1
    border.color: UbuntuColors.silk
    color: "white"
    anchors.horizontalCenter: parent.horizontalCenter

    readonly property var defaultList: [
    "mxc://ubports.chat/hMPVSdxMQoZmTqNpABGRfFTt",  // Winking cat
    "mxc://ubports.chat/uWRyfILPTBgHhLBOxXeWeNnE",  // Coffee cat
    "mxc://ubports.chat/fggtURHSHeXoZgQmMoOAwiTV",  // Show tongue cat
    "mxc://ubports.chat/pybzaOmbBZhHbjQkjibgrCyT",  // Hunsting cat
    "mxc://ubports.chat/jGNFehLdNXjbPTTCvdWaWziN",  // Loving cat
    "mxc://ubports.chat/rPiZBdRsiZrSnlvgIMHPidqn",  // Sad cat
    "mxc://ubports.chat/qhZEXxIgxWxVRLUtButgsbbM",  // Playing cat
    "mxc://ubports.chat/YcHCZIjNbsktBfDfGAXMjlQc",  // Training cat
    "mxc://ubports.chat/VMfpmawEJMyRUOhUCvwMjZFO",  // Crying cat
    "mxc://ubports.chat/uaMAYHMsoEHSJPceeJjMflHC",  // Depri cat
    "mxc://ubports.chat/yJsVquEaWEGaHIenSCUwYvOy",  // Smiling cat
    "mxc://ubports.chat/WuQiokhMnFZDxLrmgmUtFclB",  // Lying cat
    "mxc://ubports.chat/eoSpmepOlclpnoasXDEBlcRO",  // Happy cat
    "mxc://ubports.chat/QaHKWggOLOwADLjSmPhnvbLq",  // Exciting cat
    "mxc://ubports.chat/JcCNzymdQdNFCwfucyDtVeFU",  // Chilling cat
    "mxc://ubports.chat/nPwnZOKkoivoAGcLZIQrXppv",  // Crying cat 2
    "mxc://ubports.chat/pKEucOjlewDWCduWWJLvnLyf",  // Sleeping cat
    "mxc://ubports.chat/mSQEBhUchahSBBJGoNstPCqs"   // Trash cat
    ]

    Rectangle {
        width: parent.width
        height: 1
        z: 10
        color: UbuntuColors.silk
        anchors.top: parent.top
        anchors.left: parent.left
    }

    ActionSelectionPopover {
        id: deleteActions
        property var contextElem
        z: 10
        actions: ActionList {
            Action {
                text: i18n.tr("Delete sticker")
                onTriggered: {
                    var url = deleteActions.contextElem.url
                    storage.query ( "DELETE FROM Media WHERE url=?", [ url ] )
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
        chatScrollView.positionViewAtBeginning ()
        messageTextField.focus = false
        visible = true
        var res = storage.query ( "SELECT * FROM Media" )
        stickerModel.clear()
        for ( var i = res.rows.length-1; i >= 0; i-- ) {
            stickerModel.append( { mediaElem: res.rows[i] } )
        }
        for ( var i = 0; i < defaultList.length; i++ ) {
            var mediaElem = {
                url: defaultList[i],
                mimetype: "image/jpeg",
                thumbnail_url: ""
            }
            stickerModel.append( { mediaElem: mediaElem } )
        }
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
                    ( (matrix.autoloadGifs && mediaElem.mimetype === "image/gif") || mediaElem.thumbnail_url === "") ?
                    MatrixNames.getLinkFromMxc ( mediaElem.url ) :
                    MatrixNames.getThumbnailLinkFromMxc ( mediaElem.thumbnail_url, Math.round (height), Math.round (height) )
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
        model: ListModel { id: stickerModel }
    }
    
    states: State {
        name: "visible"; when: stickerInput.visible
        PropertyChanges {
            target: stickerInput
            opacity: 1
        }
    }

    transitions: Transition {
        NumberAnimation { property: "opacity"; duration: 300 }
    }

}
