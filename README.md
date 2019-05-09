![](https://i.imgur.com/wi7RlVt.png)

<p align="center">
  <a target="new" href="https://open-store.io/app/fluffychat.christianpauly"><img width="200px" src="https://christianpauly.gitlab.io/fluffychat-website/assets/images/downloadButton.jpg" /></a> <a href="https://snapcraft.io/fluffychat"><img alt="Get it from the Snap Store" style="height: 66.6px;" src="https://snapcraft.io/static/images/badges/en/snap-store-black.svg"></a><br>
  <a href="https://matrix.to/#/#fluffychat:matrix.org" target="new">Join the community</a> - <a href="https://metalhead.club/@krille" target="new">Follow me on Mastodon</a> - <a href="https://hosted.weblate.org/projects/fluffychat/" target="new">Translate FluffyChat</a> - <a href="https://gitlab.com/ChristianPauly/fluffychat-website" target="new">Translate the website</a> - <a href="https://christianpauly.gitlab.io/fluffychat-website/faq.html" target="new">FAQ</a> - <a href="https://christianpauly.gitlab.io/fluffychat-website/" target="new">Website</a>
 </p>
<br>
<br>
<p>
  <img src="https://christianpauly.gitlab.io/fluffychat-website/assets/images/screenshot20181026_144145721.png" width="19%" />
  <img src="https://christianpauly.gitlab.io/fluffychat-website/assets/images/screenshot20181026_144832172.png" width="19%" />
  <img src="https://christianpauly.gitlab.io/fluffychat-website/assets/images/screenshot20181026_144549035.png" width="19%" />
  <img src="https://christianpauly.gitlab.io/fluffychat-website/assets/images/screenshot20181026_144653603.png" width="19%" />
  <img src="https://christianpauly.gitlab.io/fluffychat-website/assets/images/screenshot20181026_144726947.png" width="19%" />
</p>

# Features
 * Single and group chats
 * Send images and files
 * ContentHub integration
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
 * Search for messages and files

#### How to build

1. Clone this repo:
```
git clone --recurse-submodules https://gitlab.com/ChristianPauly/fluffychat
cd fluffychat
```

##### Build Click for Ubuntu Touch

2. Install clickable as described here: https://gitlab.com/clickable/clickable

3. Build with clickable
```
clickable build-libs
clickable click-build
```

##### Build Snap for Desktop

2. Install snapcraft as described here: https://snapcraft.io

3. Build with snapcraft and install
```
snapcraft --debug
snap install [filename].snap --dangerous
```

# Special thanks to
<a href="https://www.regionetz.net"><img src="https://www.regionetz.net/wp-content/uploads/2017/12/logo.png" width="19%" /></a>
Regionetz is an ISP company from southern Germany and hosts the official server "ubports.chat" as well as the website of fluffychat. Special thanks to the owner Norbert Herter.

* <a href="https://github.com/fabiyamada">Fabiyamada</a> is a graphics designer from Brasil and has made the fluffychat logo and the banner. Big thanks for her great designs.

* <a href="https://github.com/advocatux">Advocatux</a> has made the Spanish translation with great love and care. He always stands by my side and supports my work with great commitment.

* Thanks to Mark for all his support and the chat background.

* Thanks to Tim Sueberkrueb for the snap version

* Also thanks to all translators and testers! With your help, fluffychat is now available in more than 12 languages.
