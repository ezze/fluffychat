import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Item {

    Connections {
        target: ContentHub
        onImportRequested: startImport(transfer)
        onShareRequested: startImport(transfer)
    }

    function startImport ( transfer ) {
        console.log("NEW IMPORT!!!!!!", JSON.stringify(transfer))
        mainStack.toStart()
        shareObject = transfer
    }

}
