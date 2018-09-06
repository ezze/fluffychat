import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: userSettings

    Dialog {
        id: dialogue
        title: usernames.getById ( activeUser )

        Component.onCompleted: {
            storage.transaction ( "SELECT avatar_url FROM Users WHERE matrix_id='" + activeUser + "'", function ( res ) {
                if ( res.rows.length === 1 ) avatar.mxc = res.rows[0].avatar_url
            })
        }

        Avatar {
            id: avatar
            width: parent.width
            name: dialogue.title
        }

        SettingsListItem {
            name: i18n.tr("Close")
            icon: "close"
            onClicked: PopupUtils.close(dialogue)
        }

    }

}
