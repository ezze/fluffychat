import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Page {
    opacity: 0.1
    Component.onCompleted: {
        opacity = 1
    }
    NumberAnimation on opacity { to: 1; duration: 300 }
}
