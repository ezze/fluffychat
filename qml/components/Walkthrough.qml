/*
 * Copyright (C) 2014-2015
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Nekhelesh Ramananthan <nik90@ubuntu.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Upstream location:
 * https://github.com/krnekhelesh/flashback
 */

import QtQuick 2.9
import Ubuntu.Components 1.3
import "../models"

Page {
    id: walkthrough

    // Property to set the app name used in the walkthrough
    property string appName

    // Property to check if this is the first run or not
    property bool isFirstRun: true

    // Property to store the slides shown in the walkthrough (Each slide is a component defined in a separate file for simplicity)
    property list<Component> model

    // Property to signal walkthrough completion
    signal finished

    // Do not show the Page Header
    head {
        visible: false
        locked: true
    }

    // Global keyboard shortcuts
    focus: true
    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Left:   //  Left   Previous slide
            previousSlide()
            break;
        case Qt.Key_Right:  //  Right  Next slide
            nextSlide()
            break;
        }

        // Prevent the event from propagating to the MainView
        event.accepted = true
    }

    // Go to next slide, if possible
    function nextSlide() {
        if (listView.currentIndex < 3) {
            listView.currentIndex++
        }
    }

    // Go to previous slide, if possible
    function previousSlide() {
        if (listView.currentIndex > 0) {
            listView.currentIndex--
        }
    }

    // ListView to show the slides
    ListView {
        id: listView
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: slideIndicator.top
        }

        model: walkthrough.model
        snapMode: ListView.SnapOneItem
        orientation: Qt.Horizontal
        highlightMoveDuration: UbuntuAnimation.FastDuration
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true

        delegate: Item {
            width: listView.width
            height: listView.height
            clip: true

            Loader {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    margins: units.gu(2)
                    top: parent.top
                }
                sourceComponent: modelData
                width: units.gu(36)
            }
        }
    }

    Icon {
        id: backIcon
        anchors {
            bottom: parent.bottom
            right: slideIndicator.left
            margins: units.gu(2)
        }
        color: settings.darkmode ? "white" : "black"
        height: units.gu(2)
        name: "go-previous"
        width: height
        asynchronous: true
        visible: listView.currentIndex > 0
    }

    MouseArea {
        anchors {
            bottom: parent.bottom
            horizontalCenter: backIcon.horizontalCenter
        }
        height: units.gu(6)
        width: height

        onClicked: previousSlide()

        Rectangle {
            anchors {
                fill: parent
            }
            color: settings.darkmode ? "white" : "black"
            opacity: parent.pressed ? 0.1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.FastDuration
                }
            }
        }
    }

    // Indicator element to represent the current slide of the walkthrough
    Row {
        id: slideIndicator
        height: units.gu(6)
        spacing: units.gu(2)
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Repeater {
            model: walkthrough.model.length
            delegate: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
                height: width
                width: units.gu(1.5)
                color: listView.currentIndex == index ? settings.mainColor : UbuntuColors.slate
                radius: width
            }
        }
    }

    Icon {
        id: nextIcon
        anchors {
            bottom: parent.bottom
            left: slideIndicator.right
            margins: units.gu(2)
        }
        color: settings.darkmode ? "white" : "black"
        height: units.gu(2)
        name: "go-next"
        width: height
        asynchronous: true
    }

    MouseArea {
        anchors {
            bottom: parent.bottom
            horizontalCenter: nextIcon.horizontalCenter
        }
        height: units.gu(6)
        width: height

        onClicked: listView.currentIndex !== listView.count-1 ? nextSlide() : walkthrough.finished()

        Rectangle {
            anchors {
                fill: parent
            }
            color: settings.darkmode ? "white" : "black"
            opacity: parent.pressed ? 0.1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.FastDuration
                }
            }
        }
    }

    Component.onCompleted: {
        if ( settings.walkthroughFinished ) {
            nextSlide()
            nextSlide()
        }
        forceActiveFocus()
    }
}
