import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Rectangle {

    property var defaultTime: 8000
    property bool stateVisible: false

    id: toast
    anchors.bottom: parent.bottom
    anchors.bottomMargin: units.gu(4)
    anchors.horizontalCenter: parent.horizontalCenter
    width: label.width + units.gu(2)
    height: label.height + units.gu(2)
    color: Qt.rgba(0,0,0,0.75)
    radius: 30
    visible: false
    z: 5

    MouseArea {
        anchors.fill: parent
        onClicked: { toast.stateVisible = false }
    }

    states: [
    State { when: stateVisible;
        PropertyChanges {   target: toast; opacity: 1.0    }
    },
    State { when: !stateVisible;
        PropertyChanges {   target: toast; opacity: 0.0    }
    }
    ]
    transitions: Transition {
        NumberAnimation { property: "opacity"; duration: 500}
    }

    function show ( str, time ) {
        if ( !time ) time = defaultTime
        label.text = str
        var maxWidth = mainStackWidth - units.gu(4)
        if ( label.width > maxWidth ) label.width = maxWidth
        visible = true
        stateVisible = true
        function Timer() {
            return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
        }
        var timer = new Timer()
        timer.interval = time
        timer.repeat = false
        timer.triggered.connect(function () {
            if ( label.text === str ) toast.stateVisible = false
        })
        timer.start();
    }

    Label {
        id: label
        elide: Text.ElideMiddle
        anchors.centerIn: parent
        text: ""
        color: "#FFFFFF"
        wrapMode: Text.Wrap
    }

}
