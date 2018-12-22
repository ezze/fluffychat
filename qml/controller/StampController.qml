import QtQuick 2.9
import Ubuntu.Components 1.3

Item {

    function getChatTime ( stamp ) {
        var date = new Date ( stamp )
        var now = new Date ()
        var locale = Qt.locale()
        var fullTimeString = date.toLocaleTimeString(locale, Locale.ShortFormat)


        if ( date.getDate()  === now.getDate()  &&
        date.getMonth() === now.getMonth() &&
        date.getFullYear() === now.getFullYear() ) {
            return fullTimeString
        }

        return date.toLocaleString(locale, Locale.ShortFormat)
    }

    function getAgoFormat ( ago ) {
        ago = Math.round(ago / 1000)
        if ( ago < 60 ) return i18n.tr("1 minute")
        else {
            ago = Math.round(ago / 60)
            if ( ago < 60 ) return i18n.tr("%1 minutes").arg(ago)
            else {
                ago = Math.round(ago / 60)
                if ( ago < 24 ) return i18n.tr("%1 hours").arg(ago)
                else {
                    ago = Math.round(ago / 24)
                    return i18n.tr("%1 days").arg(ago)
                }
            }
        }
    }

}
