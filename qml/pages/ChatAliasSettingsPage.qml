import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent


    Component.onCompleted: init ()

    function init () {

    }

    header: FcPageHeader {
        title:  i18n.tr('Public chat addresses')
    }
