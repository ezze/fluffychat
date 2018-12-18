import QtQuick 2.9
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0

Settings {

    // This is the access token for the matrix client. When it is undefined, then
    // the user needs to sign in first
    property var token

    // The username is the local part of the matrix id
    property var username

    // The server is the domain part of the matrix id
    property var server

    // The ID server maps the emails and phone numbers to matrix IDs
    property var id_server: defaultIDServer

    // The device ID is an unique identifier for this device
    property var deviceID

    // The device name is a human readable identifier for this device
    property var deviceName

    // This points to the position in the synchronization history, that this
    // client has got
    property var since

    // This is the version of the database:
    property var dbversion

    // Is the pusher set?
    property var pushToken
    property var pushUrl
    property var pushDeviceName

    // Dark mode enabled?
    property var darkmode: false

    // The path to the chat background
    property var chatBackground

    // Chat settings: Send typing notification?
    property var sendTypingNotification: false

    // Chat settings: Hide less important events?
    property var hideLessImportantEvents: false

    // Chat settings: Show member change events?
    property var showMemberChangeEvents: false

    // Chat settings: Autoload gifs?
    property var autoloadGifs: false

    // Are archived chats synchronized too?
    property var requestedArchive: false

    // The main color and the 'h' value
    property var mainColor: Qt.hsla(mainColorH, 0.67, 0.44, 1)
    property var brightMainColor: Qt.hsla(mainColorH, 0.67, 0.7, 1)
    property var brighterMainColor: Qt.hsla(mainColorH, 0.67, 0.85, 1)
    property var mainColorH: defaultMainColorH

    // The two country ISO name and phone code:
    property var countryCode: i18n.tr("USA")
    property var countryTel: i18n.tr("1")
}
