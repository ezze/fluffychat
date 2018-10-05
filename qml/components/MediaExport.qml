/*
* Copyright (C) 2012-2014 Canonical, Ltd.
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
*/

import QtQuick 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3 as Popups
import Ubuntu.Content 1.3 as ContentHub

Item {
    id: root

    property alias contentType: sourcePicker.contentType


    function share( content, type ) {
        contentType = type
        PopupUtils.open(dialogue)
    }


    Component {
        id: contentHubDialog

        Popups.PopupBase {
            id: dialogue

            property alias activeTransfer: signalConnections.target
            focus: true

            Rectangle {
                anchors.fill: parent

                Component {
                    id: itemTemplate
                    ContentItem {}
                }

                ContentPeerPicker {
                    id: sourcePicker
                    contentType: ContentType.Pictures
                    handler: ContentHandler.Share

                    showTitle: false

                    onPeerSelected: {
                        console.log('Sharing:'+link)
                        activeTransfer = sourcePicker.peer.request()

                        if (activeTransfer !== null) {
                            activeTransfer.items = results
                            activeTransfer.state = ContentTransfer.Charged;
                        }

                        PopupUtils.close(dialogue)
                    }

                    onCancelPressed: {
                        PopupUtils.close(dialogue)
                    }

                    Component.onCompleted: {
                        console.log("Completed ....")
                    }
                }

                ContentTransferHint {
                    id: importHint
                    anchors.fill: parent
                    activeTransfer: sharePage.activeTransfer
                }

            }

        }
    }
