import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {

    visible: { temp || layout.title.text.toUpperCase().indexOf( searchField.displayText.toUpperCase() ) !== -1 }
    height: visible ? layout.height : 0

    onClicked: usernames.showUserSettings ( matrixid )

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainFontColor
        subtitle.text: medium.replace("msisdn","📱").replace("email","✉").replace("matrix","💬") + " " + address

        Avatar {
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            width: units.gu(4)
            height: width
            mxc: avatar_url || ""
            onClickFunction: function () {
                usernames.showUserSettings ( matrixid )
            }
        }
    }
}
