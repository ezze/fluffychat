![](https://i.imgur.com/wi7RlVt.png)

<p align="center">
  <a target="new" href="https://open-store.io/app/fluffychat.christianpauly"><img width="200px" src="/docs/images/downloadButton.jpg" /></a><br>
  <a href="https://matrix.to/#/#fluffychat:matrix.org" target="new">Join the community</a> - <a href="https://metalhead.club/@krille" target="new">Follow me on Mastodon</a> - <a href="https://hosted.weblate.org/projects/fluffychat/" target="new">Help with translations</a>
 </p>
<br>
<br>
<p>
  <img src="/docs/screenshots/screenshot20181026_144145721.png" width="19%" />
  <img src="/docs/screenshots/screenshot20181026_144832172.png" width="19%" />
  <img src="/docs/screenshots/screenshot20181026_144549035.png" width="19%" />
  <img src="/docs/screenshots/screenshot20181026_144653603.png" width="19%" />
  <img src="/docs/screenshots/screenshot20181026_144726947.png" width="19%" />
</p>

# Features
 * Single and group chats
 * Send images and files
 * Offline chat history
 * Push Notifications
 * Account settings
 * Display user avatars
 * Themes, chat wallpapers and dark mode
 * Device management
 * Edit chat settings and permissions
 * Kick, ban and unban users
 * Display and edit chat topics
 * Change chat&user avatars
 * Archived chats
 * Display communities
 * User status (presences)
 * Display contacts and find contacts with their phone number or email address
 * Discover public chats on the user's homeserver
 * Registration (currently only working with ubports.chat and NOT with matrix.org due captchas)

##### Planned features
 * End2End-encryption
 * Sharing files
 * Search for messages and files

# FAQ

#### I do not receive push notifications :-(
 * Have you tried to logout and login?
 * Do you have an Ubuntu One account in the system settings?
 * When you go into fluffychat -> Settings -> Notifications -> Targets: Is there a device "UbuntuPhone"?
 * Do you have the latest version of fluffychat installed from the OpenStore?
 * Have you tried to turn airplaine mode on and off again? Sometimes notifications are sent with a delay from the UBports push service (will be fixed soon)
 If you still have the problem, then please contact me at the room: #fluffychat:matrix.org

#### I can not connect to my homeserver with port 8448
Sorry! 😕 On port 8448 the most homeservers use a different ssl certificate, which causes an error. Currently the xmlhttprequest in QML
does not allow those certificates.

#### Which /commands are available?
* /me (Will send msgtype: m.emote)
Displays an action.

* /whisper (Will send msgtype: m.fluffychat.whisper)
The message text will be very small

* /roar (Will send msgtype: m.fluffychat.roar)
The message text will be very large, bold and in capital letters

* /shrug
Puts ¯&#92;_(ツ)_/¯ at the start of the message

#### Which uri will open fluffychat?
* fluffychat://@user:server.abc will launch the user profile

* fluffychat://#room:server.abc will join the room with the given alias

* fluffychat://!chatid:server.abc will open the room with the given ID

#### I can not connect to my homeserver (self signed certificate)
The same problem ... I recommend you to use a letsencrypt certificate.

#### How can I support FluffyChat?
* <a href="https://www.patreon.com/krillechritzelius">Patreon</a>
* <a href="https://liberapay.com/KrilleChritzelius">Liberapay</a>

#### How to build

1. Install clickable as described here: https://github.com/bhdouglass/clickable

2. Clone this repo:
```
git clone https://github.com/ChristianPauly/fluffychat
cd fluffychat
```

3. Build with clickable
```
clickable click-build
```

# Special thanks to
<a href="https://www.regionetz.net"><img src="https://www.regionetz.net/wp-content/uploads/2017/12/logo.png" width="19%" /></a>
Regionetz is an ISP company from southern Germany and hosts the official server "uborts.chat" as well as the website of fluffychat. Special thanks to the owner Norbert Herter.

* <a href="https://github.com/fabiyamada">Fabiyamada</a> is a graphics designer from Brasil and has made the fluffychat logo and the banner. Big thanks for her great designs.

* <a href="https://github.com/advocatux">Advocatux</a> has made the Spanish translation with great love and care. He always stands by my side and supports my work with great commitment.

* Thanks to Mark for all his support and the chat background.

* Also thanks to all translators and testers! With your help, fluffychat is now available in 5 languages.
