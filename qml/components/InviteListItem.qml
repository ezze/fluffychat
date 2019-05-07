import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/InviteListItemActions.js" as ItemActions

ListItem {

    height: visible * layout.height
    visible: {
        searchField.searchMatrixId ? matrixid.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
        : layout.title.text.toUpperCase().indexOf( searchField.upperCaseText ) !== -1
    }

    color: mainLayout.darkmode ? "#202020" : "white"

    property var matrixid: matrix_id
    property var displayname: name
    property var tempElement: temp

    onClicked: ItemActions.invite ( matrixid, displayname )

    ListItemLayout {
        id: layout
        title.text: name
        title.color: mainLayout.mainFontColor

        Avatar {
            name: layout.title.text
            SlotsLayout.position: SlotsLayout.Leading
            width: units.gu(4)
            height: width
            mxc: avatar_url || ""
            onClickFunction: function () {
                MatrixNames.showUserSettings ( matrixid )
            }
        }
        Icon {
            SlotsLayout.position: SlotsLayout.Trailing
            width: units.gu(2)
            height: width
            name: "contact-new"
        }
    }
}
