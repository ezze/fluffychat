// File: ChatTimeDisplay.js
// Description: Returns a string with the correct chat time from a timestamp

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
