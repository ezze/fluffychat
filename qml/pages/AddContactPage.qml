import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        id: header
        title: i18n.tr('Start new private chat')

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "ok"
                text: i18n.tr('Start new private chat')
                onTriggered: {
                    var data = {
                        "is_direct": true,
                        "preset": "private_chat"
                    }

                    var input = contactTextField.displayText
                    if ( input.charAt[0] === "@" && input.indexOf(":") !== -1 ) {
                        // The input is a matrix ID
                        data.invite = [ input ]
                    }
                    else if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test( input )) {
                        // The input is a valid email address
                        data.invite_3pid = [ {
                            id_server: settings.id_server,
                            medium: "email",
                            address: input
                        } ]
                    }
                    else return toast.show( i18n.tr("You need to enter a valid Email address or Matrix ID!") )

                    matrix.post( "/client/r0/createRoom", data, function ( response ) {
                        activeChat = response.room_id
                        mainStack.toStart ()
                        mainStack.push (Qt.resolvedUrl("./ChatPage.qml"))
                    } )
                }
            }
            ]
        }
    }

    TextField {
        id: contactTextField
        width: parent.width - units.gu(4)
        anchors {
            top: header.bottom
            margins: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
        focus: true
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Email or full username...")
    }

    Icon {
        source: "../../assets/info-logo.svg"
        color: settings.mainColor
        width: parent.width / 2
        height: width
        anchors.centerIn: parent
    }
    Label {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: units.gu(2)
        }
        wrapMode: Text.Wrap
        text: i18n.tr("Your full username is: <b>%1</b>").arg(matrix.matrixid)
    }

}
