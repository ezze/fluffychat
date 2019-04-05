import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0

Connectivity {
    onOnlineChanged: matrix.online = online
}
