import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Change the main color")
        Rectangle {
            height: units.gu(0.2)
            width: parent.width
            color: mainLayout.mainColor
        }

        Slider {
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            value: mainLayout.mainColorH*100
            onValueChanged: mainLayout.mainColorH = value / 100
            function formatValue ( v ) { return i18n.tr("Hue: %1").arg(Math.round(v)) }
        }


        Row {
            width: parent.width
            spacing: units.gu(1)
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Reset")
                onClicked: mainLayout.mainColorH = mainLayout.defaultMainColorH
            }
            Button {
                width: (parent.width - units.gu(1)) / 2
                text: i18n.tr("Close")
                color: mainLayout.mainColor
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }
}
