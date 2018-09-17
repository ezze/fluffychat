import QtQuick 2.4
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

    // The displayname is the username which the user has chosen
    property var displayname

    // This is the mxc uri for the avatar of the user
    property var avatar_url

    // This points to the position in the synchronization history, that this
    // client has got
    property var since

    // This is the version of the database:
    property var dbversion

    // Is the pusher set?
    property var pushToken

    // The main color of the theme
    property var mainColor: defaultMainColor

    // Dark mode enabled?
    property var darkmode: false

    // The path to the chat background
    property var chatBackground

    // Security & Privacy: Send typing notification?
    property var sendTypingNotification: true

    // Are archived chats synchronized too?
    property var requestedArchive: false
}
