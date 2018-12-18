import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0

/* =============================== MEDIA CONTROLLER ===============================

Little helper controller for downloading thumbnails and all content via mxc uris.
*/

Item {

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
        width = Math.round(width)
        height = Math.round(height)
        if ( mxc === undefined || mxc === "" ) return ""
        if ( Connectivity.online ) {
            return "https://" + settings.server + "/_matrix/media/r0/thumbnail/" + mxc.replace("mxc://","") + "?width=" + width + "&height=" + height + "&method=scale"
        }
        else {
            return downloadPath + mxc.split("/")[3]
        }

    }


    function getLinkFromMxc ( mxc ) {
        if ( mxc === undefined ) return ""
        var mxcID = mxc.replace("mxc://","")
        return "https://" + settings.server + "/_matrix/media/r0/download/" + mxcID + "/"
    }
}
