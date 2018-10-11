import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.DownloadManager 1.2

/* =============================== MEDIA CONTROLLER ===============================

Little helper controller for downloading thumbnails and all content via mxc uris.
*/

Item {

    property var callback: console.log("Download finished")
    property var isDownloading: false


    function getThumbnailFromMxc ( mxc, width, height ) {
        if ( mxc === undefined || mxc === null ) return ""

        var mxcID = mxc.replace("mxc://","")
        //Qt.resolvedUrl()

        if ( !isDownloading ) {
            isDownloading = true
            //downloader.download ( getThumbnailLinkFromMxc ( mxc, width, height ) )
        }


        return getThumbnailLinkFromMxc ( mxc, width, height )
    }


    function getThumbnailLinkFromMxc ( mxc, width, height ) {
        if ( mxc === undefined || mxc === "" ) return ""
        return "https://" + settings.server + "/_matrix/media/r0/thumbnail/" + mxc.replace("mxc://","") + "?width=" + width + "&height=" + height + "&method=scale"
    }


    function getLocalThumbnailFromMxc ( mxc ) {
        if ( mxc === undefined ) return ""

        var mxcID = mxc.replace("mxc://","").split("/")[1]
        return "../../Downloads/%1".arg(mxcID)
    }


    function downloadThumbnailFromMxc ( mxc, width, height, cb ) {
        callback = cb
        downloader.download ( getThumbnailLinkFromMxc ( mxc, width, height ) )
    }


    function getLinkFromMxc ( mxc ) {
        if ( mxc === undefined ) return ""
        var mxcID = mxc.replace("mxc://","")
        return "https://" + settings.server + "/_matrix/media/r0/download/" + mxcID + "/"
    }


    SingleDownload {
        id: downloader
        //onProgressChanged: console.log("Progress:", progress)
        onFinished: {
            console.log ( "Downloaded: ", path )
            isDownloading = false
            callback ( path )
        }
    }

}
