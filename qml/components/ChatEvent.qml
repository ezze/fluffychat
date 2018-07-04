import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Rectangle {
    id: message
    //property var event
    property var sending: event.sending || false
    property var isStateEvent: event.type !== "m.room.message"
    property var sent: event.sender.toLowerCase() === matrix.matrixid.toLowerCase()

    width: root.width
    height: messageBubble.height + units.gu(1)
    color: "transparent"
    opacity: sending ? 0.66 : isStateEvent ? 0.75 : 1


    // When the width of the "window" changes (rotation for example) then the maxWidth
    // of the message label must be calculated new. There is currently no "maxwidth"
    // property in qml.
    onWidthChanged: {
        messageLabel.width = undefined
        var maxWidth = width - avatar.width - units.gu(5)
        if ( messageLabel.width > maxWidth ) messageLabel.width = maxWidth
        else messageLabel.width = undefined
    }


    // When there something changes inside this message component, then this function
    // must be triggered.
    function update () {
        metaLabel.text = (event.displayname || event.sender) + " " + stamp.getChatTime ( event.origin_server_ts )
        avatar.mxc = event.avatar_url
    }

    Avatar {
        id: avatar
        mxc: event.avatar_url
        anchors.left: sent ? undefined : parent.left
        anchors.right: sent ? parent.right : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        opacity: event.sameSender ? 0 : 1
        visible: !isStateEvent
    }


    Rectangle {
        id: messageBubble
        z: 2
        anchors.left: sent ? undefined : avatar.right
        anchors.right: sent ? avatar.left : undefined
        anchors.centerIn: isStateEvent ? parent : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        border.width: 0
        border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
        anchors.margins: 5
        color: (sent || isStateEvent) ? "#FFFFFF" : settings.mainColor
        radius: units.gu(2)
        height: messageLabel.height + !isStateEvent * metaLabel.height + thumbnail.height + units.gu(2)
        width: Math.max( messageLabel.width + units.gu(2), (metaLabel.width + (event.sending ? units.gu(1.5) : 0)) + units.gu(2), thumbnail.width )

        MouseArea {
            width: thumbnail.width
            height: thumbnail.height
            Image {
                id: thumbnail
                visible: !isStateEvent && event.content.msgtype === "m.image"
                width: visible ? Math.max( units.gu(24), messageLabel.width + units.gu(2) ) : 0
                source: event.content.url ? media.getThumbnailLinkFromMxc ( event.content.url, Math.round (width), Math.round (width) ) : ""
                anchors.top: parent.top
                anchors.left: parent.left
                fillMode: Image.PreserveAspectCrop
                onStatusChanged: {
                    if ( status === Image.Error ) {
                        source = "../../assets/network-cellular-none.svg"
                    }
                }
            }
            onClicked: Qt.openUrlExternally( media.getLinkFromMxc ( event.content.url ) )
        }


        Button {
            id: downloadButton
            text: i18n.tr("Download")
            onClicked: Qt.openUrlExternally( media.getLinkFromMxc ( event.content.url ) )
            visible: [ "m.file", "m.audio", "m.video" ].indexOf( event.content.msgtype ) !== -1
            height: visible ? units.gu(4) : 0
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: units.gu(1)
        }


        // In this label, the body of the matrix message is displayed. This label
        // is main responsible for the width of the message bubble.
        Label {
            id: messageLabel
            text: isStateEvent ? displayEvents.getDisplay ( event ) + " <font color='" + UbuntuColors.silk + "'>" + stamp.getChatTime ( event.origin_server_ts ) + "</font>" :  event.content_body || event.content.body
            color: (sent || isStateEvent) ? "black" : "white"
            wrapMode: Text.Wrap
            textSize: isStateEvent ? Label.XSmall : Label.Medium
            anchors.bottom: isStateEvent ? parent.bottom : metaLabel.top
            anchors.left: parent.left
            anchors.topMargin: units.gu(1)
            anchors.leftMargin: units.gu(1)
            anchors.bottomMargin: isStateEvent ? units.gu(1) : 0
            onLinkActivated: Qt.openUrlExternally(link)
            // Intital calculation of the max width and display URL's
            Component.onCompleted: {
                if ( !event.content_body ) event.content_body = event.content.body
                var maxWidth = message.width - avatar.width - units.gu(5)
                if ( width > maxWidth ) width = maxWidth

                if ( !isStateEvent ) {
                    var urlRegex = /(https?:\/\/[^\s]+)/g
                    var tempText = text
                    tempText = text.replace ( "&#60;", "<" )
                    tempText = text.replace ( "&#62;", "<" )
                    tempText = text.replace(urlRegex, function(url) {
                        return '<a href="%1"><font color="%2">%1</font></a>'.arg(url).arg(messageLabel.color)
                    })
                    text = tempText
                }
            }
        }


        // This label is for the meta-informations, which means it displays the
        // display name of the sender of this message and the time.
        Label {
            id: metaLabel
            text: (event.displayname || event.sender) + " " + stamp.getChatTime ( event.origin_server_ts )
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: units.gu(1)
            color: messageLabel.color
            opacity: 0.66
            textSize: Label.XSmall
            visible: !isStateEvent
        }
        // When the message is just sending, then this activity indicator is visible
        ActivityIndicator {
            id: activity
            visible: sending
            running: visible
            anchors.left: metaLabel.right
            anchors.top: messageLabel.bottom
            anchors.leftMargin: units.gu(0.25)
            width: units.gu(1.25)
            height: width
        }

    }


}
