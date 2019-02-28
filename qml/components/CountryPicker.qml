import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../scripts/countrycodes.js" as CountryData

BottomEdge {

    id: countryPicker
    height: parent.height

    onCollapseCompleted: countryPicker.destroy ()
    Component.onCompleted: commit()

    contentComponent: Page {
        id: page
        height: countryPicker.height

        header: PageHeader {
            id: header
            title: i18n.tr("Choose a country")
        }

        TextField {
            id: searchField
            property var upperCaseText: displayText.toUpperCase()
            z: 5
            anchors {
                top: header.bottom
                topMargin: units.gu(1)
                bottomMargin: units.gu(1)
                left: parent.left
                right: parent.right
                rightMargin: units.gu(2)
                leftMargin: units.gu(2)
            }
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search country name...")
        }

        ListView {
            id: countrySelector
            anchors.top: searchField.bottom
            width: parent.width
            height: parent.height - header.height - searchField.height
            model: ListModel { id: model }
            delegate: ListItem {
                property var countryName: name.toUpperCase()
                visible: { countryName.indexOf( searchField.upperCaseText ) !== -1 }
                height: visible ? layout.height : 0
                ListItemLayout {
                    id: layout
                    title.text: "<font color='grey'>(+%1)</font> ".arg(tel) + name
                }
                onClicked: {
                    matrix.countryCode = CountryData.name_to_iso[name]
                    matrix.countryTel = "" + tel
                    countryPicker.collapse ()
                }
            }

            Component.onCompleted: {
                var countries = []
                for (var c in CountryData.name_to_tel) {
                    model.append ( {
                        name: c,
                        tel: CountryData.name_to_tel[c]
                    } )
                }
            }
        }
    }
}
