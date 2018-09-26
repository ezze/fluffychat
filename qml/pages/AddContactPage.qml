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
                    loadingScreen.visible = true
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

    ContactImport { id: contactImport }

    TextField {
        id: contactTextField
        width: parent.width - units.gu(4)
        anchors {
            top: header.bottom
            margins: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Email or full username...")
        Component.onCompleted: focus = true
    }

    Label {
        id: label
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: contactTextField.bottom
            margins: units.gu(2)
        }
        wrapMode: Text.Wrap
        width: parent.width - units.gu(4)
        horizontalAlignment: Text.AlignHCenter
        text: i18n.tr("Your full username is: <b>%1</b>").arg(matrix.matrixid)
    }

    Icon {
        source: "../../assets/info-logo.svg"
        color: settings.mainColor
        width: parent.width / 1.25
        opacity: 0.3
        height: width
        anchors.centerIn: parent
    }

    Button {
        id: button
        anchors.bottom: parent.bottom
        anchors.margins: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Import from contacts")
        color: UbuntuColors.green
        onClicked: contactImport.requestContact()
    }

}
