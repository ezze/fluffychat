import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import "../components"

Item {

    Connections {
        target: ContentHub
        onShareRequested: startImport(transfer)
    }

    ContactImport { id: contactImport }

    function startImport ( transfer ) {
        console.log("NEW TRANSFER:",JSON.stringify(transfer))
        if ( transfer.contentType === ContentType.Links || transfer.contentType === ContentType.Text ) {
            mainStack.toStart()
            shareObject = transfer
        }
        else if ( transfer.contentType === ContentType.Contacts ) {
            for ( var i = 0; i < transfer.items.length; i++ ) {
                contactImport.mediaReceived ( String(transfer.items[i].url) )
            }
        }
        else toast.show (i18n.tr("We are sorry. 😕 Sharing photos, videos or files is not yet supported..."))
    }

}
