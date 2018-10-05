![](https://i.imgur.com/wi7RlVt.png)

<a target="new" href="https://open-store.io/app/fluffychat.christianpauly"><img width="200px" src="/docs/downloadButton.jpg" /></a>

Community: https://matrix.to/#/#fluffychat:matrix.org

Follow me on Mastodon: https://metalhead.club/@krille

<p>
  <img src="/docs/screenshots/screenshot20180710_172017850.png" width="19%" />
  <img src="/docs/screenshots/screenshot20180710_172051018.png" width="19%" />
  <img src="/docs/screenshots/screenshot20180710_172126491.png" width="19%" />
  <img src="/docs/screenshots/screenshot20180710_172212362.png" width="19%" />
  <img src="/docs/screenshots/screenshot20180710_172240709.png" width="19%" />
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
 * Display contacts and find contacts with their phone number or email address
 * Discover public chats on the user's homeserver
 * Registration (currently only working with ubports.chat and NOT with matrix.org due captchas)

##### Planned features
 * End2End-encryption
 * Sharing files
 * Android support

# FAQ

#### Why are you not just contributing to uMatriks?
uMatriks is great and it's superb, that someone has created a Matrix Client for Ubuntu Touch. But sometimes you have a so
detailed vision of a user interface, which you want to implement, that you can not just contribute to an existing project.
However, I would like to work with the uMatriks developers together. We could use the same push gateway for example.

#### Why fluffy? Why is it pink and why are there so much emojis in the source code?
The most opensource messengers, like Conversations (XMPP) or Riot (Matrix) are great but have a very technical design. They are not much more complicated then messengers like Telegram or Whatsapp but I think they *feel* complicated, because of the user interface.
FluffyChat should look like a messenger, which targets also children. Because then, it will *feel* like "easy as a snap".
You don't like the colors? In the next versions, you will be able to change the colors and themes in the settings, so don't worry. ;-)

#### I do not receive push notifications :-(
 * Have you tried to logout and login?
 * Do you have an Ubuntu One account in the system settings?
 * When you go into fluffychat -> Settings -> Notifications -> Targets: Is there a device "UbuntuPhone"?
 * Do you have the latest version of fluffychat installed from the OpenStore?
 * Have you tried to turn airplaine mode on and off again? Sometimes notifications are sent with a delay from the UBports push service (will be fixed soon)
 If you still have the problem, then please contact me at the room: #fluffychat:matrix.org

#### How are push notifications working?
The notifications are sent from the matrix homeserver to the fluffychat push-gateway at: https://github.com/ChristianPauly/fluffychat-push-gateway
This gateway just beams the push to https://push.ubports.com/notify via https. The push-gateway is currently on my own server! I am NOT saving any data! It is just forwarding! However you can just host your own gateway if you want. There is currently no end-to-end encryption in fluffychat so you should not send any message-content from your homeserver, if you don't trust fluffychat or ubports!

#### I can not connect to my homeserver with port 8448
Sorry! 😕 On port 8448 the most homeservers use a different ssl certificate, which causes an error. Currently the xmlhttprequest in QML
does not allow those certificates.

#### I can not connect to my homeserver (self signed certificate)
The same problem ... I recommend you to use a letsencrypt certificate.

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

* Also thanks to all translators and testers! With your help, fluffychat is now available in 5 languages.
