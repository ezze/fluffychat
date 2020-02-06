import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../scripts/MatrixNames.js" as MatrixNames
import "../scripts/UserDevicesPageActions.js" as PageActions
import "../components"

Page {
    anchors.fill: parent
    id: userDevicesPage

    property var matrix_id: activeUser
    property bool loading: true
    property bool isTracking: false
    property var activeDevice: {}
    signal reload

    onReload: PageActions.init()

    Component.onCompleted: PageActions.init ()

    header: PageHeader {
        id: header
        title: i18n.tr("Devices of %1").arg(MatrixNames.getById(matrix_id))
    }

    ListModel { id: model }

    ListView {
        id: chatListView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        delegate: DeviceKeyListItem {}
        model: model
        clip: true
    }

    Label {
        id: label
        text: loading ? i18n.tr("Loading…") : i18n.tr("No devices found")
        textSize: Label.Large
        color: UbuntuColors.graphite
        anchors.centerIn: parent
        visible: loading || model.count === 0
    }

}
