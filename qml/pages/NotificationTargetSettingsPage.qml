import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var currentTarget

    function getTargets () {
        matrix.get ( "/client/r0/pushers", null, function ( response ) {
            targetList.children = ""
            for ( var i = 0; i < response.pushers.length; i++ ) {
                var newListItem = Qt.createComponent("../components/TargetListItem.qml")
                newListItem.createObject(targetList, { target: response.pushers[i] } )
            }
        })
    }


    header: FcPageHeader {
        title: i18n.tr('Notification targets')
    }

    ScrollView {

        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: mainStackWidth
            id: targetList

            Component.onCompleted: getTargets ()
        }
    }

    TargetInfoDialog { id: targetInfoDialog }
}
