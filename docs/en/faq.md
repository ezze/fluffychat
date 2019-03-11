---
layout: default
title: FAQ
lang: en
---
# Frequently Asked Questions

*   [Account settings](#1)
*   [Start chatting](#2)
*   [Chat settings](#3)
*   [Bridge to other chat systems](#4)
*   [Error handling](#5)
*   [About FluffyChat](#6)

## Account settings<a id="1"/>

#### How can I reset my password?<a id="1-1"/>

You must connect an email address with your account. This can be done in the account settings. If you don't have connected an email address, you have to contact the support of your homeserver. ([What is a homeserver?](#1-5))  
[Click here to reset your password](https://www.ubports.chat/#/forgot_password).

#### How can I create a new account?<a id="1-2"/>

1.  If you are already logged in in FluffyChat then go to the settings and tab on "Logout" at the bottom.
2.  Choose a new username and make sure that "Create an account" is checked.
3.  If you want to create an account on another homeserver than the default (ubports.chat), go to the top left menu and change the homeserver. ([What is a homeserver?](#1-5))
4.  Go to "Log In" and choose a new password.

#### How can I log in my old account?<a id="1-3"/>

1.  If you are already logged in in FluffyChat then go to the settings and tab on "Logout" at the bottom.
2.  Enter the username or your Matrix ID of your old account. ([What is a Matrix ID?](#1-4)) If you don't remember your username or Matrix ID but you remember the phone number connected with your account, then you can just enter any username and enter the correct phone number in the next step. The username will be automatically found.
3.  (Optional) Enter the phone number of your old account.
4.  If your old account is not on the default homeserver (ubports.chat), go to the top left menu and change the homeserver. ([What is a homeserver?](#1-5))
5.  Make sure that "Create an account" is **not** checked.
6.  Go to "Log In" and enter your password. ([Password forgotten?](#1-1))

#### What is a Matrix ID?<a id="1-4"/>

Your Matrix ID is your unique identifier in the Matrix network. It is a combination of your username and your homeserver. ([What is a homeserver?](#1-5))  
The format of a Matrix ID is simple: <code>@username:homeserver</code>. For example, if your username is "alice" and your homeserver is "homeserver.abc", then your Matrix ID is: <code>@alice:homeserver.abc</code>

#### What is a homeserver?<a id="1-5"/>

Matrix is a federated network of homeservers. What does this mean? There is no centralized "FluffyChat server" but there are multiple homeservers you can use. You are free to pick the homeserver you want. Like the email all users from all homeservers can communicate with eachother. There is a default homeserver on FluffyChat named "https://ubports.chat". You are able to host your own homeserver. [Click here for a guide how to start](https://matrix.org/docs/guides/installing-synapse).

#### What is an identity server?<a id="1-6"/>

Users in Matrix are identified internally via their Matrix ID. However, existing 3rd party ID (3PID) namespaces such as email addresses or phone numbers should be used publicly to identify Matrix users, at least for invitation purposes. A Matrix "Identity" describes both the user ID and any other existing IDs from third party namespaces linked to their account.  
Matrix users can link third-party IDs (3PIDs) to their user ID. Linking 3PIDs creates a mapping from a 3PID to a user ID. This mapping can then be used by Matrix users in order to discover the MXIDs of their contacts. In order to ensure that the mapping from 3PID to user ID is genuine, the intention is for a globally federated cluster of trusted "Identity Servers" (IS) be used to verify the 3PID and persist and replicate the mappings. Usage of an IS is not required in order for a client application to be part of the Matrix ecosystem. However, without one clients will not be able to look up user IDs using 3PIDs.

## Start chatting<a id="2"/>

#### How can I start a new chat?<a id="2-1"/>

1.  Click on "Add Chat" at the start page or swipe up from the bottom on phones.
2.  Choose your contacts you want to chat and click on "Start a new chat". Alternatively you can create a new group and invite contacts.
3.  If you don't find a contact, you can [add them by their phone number](#2-4) or enter their Matrix ID in the search field. ([What is a Matrix ID?](#1-4))

#### How can I join a public chat?<a id="2-2"/>

A public chat has one or more public addresses called aliases. They always start with '#' and end with ':homeserver.abc'. For example: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org). Just click on the link to participate in the chat.
You can manually enter the alias by going to "Start a new chat" -> "Public chats".

#### How can I join a community?<a id="2-3"/>

A public chat has one or more public addresses called aliases. They always start with '+' and end with ':homeserver.abc'. For example: [+ubports\_community:matrix.org](fluffychat://+ubports_community:matrix.org). Just click on the link to see all chats associated with this community. For more features, visit the [desktop web app](https://www.ubports.chat).

#### How can I add contacts by their phone number?<a id="2-4"/>

1.  Click on the "Start chat" button at the start page or swipe up from the bottom on phones.
2.  Click on the add contact button at the top right.
3.  Click on "Import from address book" and Choose your address book app.
4.  Select the contact you want to add or select all contacts and confirm.
5.  FluffyChat will search for these contacts in the identity server. ([What is an identity server?](#1-6))

#### Which /commands are available?<a id="2-5"/>

*   <code>/me</code> (Will send msgtype: m.emote) Displays an action.
*   <code>/whisper</code> (Will send msgtype: m.fluffychat.whisper) The message text will be very small
*   <code>/roar</code> (Will send msgtype: m.fluffychat.roar) The message text will be very large, bold and in capital letters
*   <code>/shrug</code> Puts ¯\\(ツ)/¯ at the start of the message

## Chat settings<a id="3"/>

#### How can I kick or ban a user from a chat?<a id="3-1"/>

You need the permission to kick or ban a user from a chat.

1.  Go to the chat
2.  Go to "Chat details" in the top right menu
3.  Find the user you want to kick or ban and swipe the user list item to the right.
4.  Click on the kick or the ban button and confirm

#### How can I change the user permissions in a chat?<a id="3-2"/>

You need the permission to change the user permissions.

1.  Go to the chat
2.  Go to "Chat details" in the top right menu
3.  Find the user you want to kick or ban and swipe the user list item to the left.
4.  Click on the desired user permission button and confirm

#### How can I change the chat topic and description?<a id="3-3"/>

You need the permission to change the chat topic and description.

1.  Go to the chat
2.  Go to "Chat details" in the top right menu
3.  Click on the top right edit button and enter the desired chat topic and/or description

#### How can I edit the chat privacy settings?<a id="3-4"/>

You need the permission to edit the chat privacy settings.

1.  Go to the chat
2.  Go to "Chat details" in the top right menu
3.  Go to "Advanced settings"
4.  Toggle or untoggle the desired options and edit the user permission options

#### What are chat aliases and how can I edit them?<a id="3-5"/>

Chat aliases are public chat addresses which can be used to join a chat. You need the chat permissions to change them.

1.  Go to the chat
2.  Go to "Chat details" in the top right menu
3.  Go to "Privacy and security"
4.  Toggle or untoggle the desired options and edit the user permission options

#### How can I send animated stickers with Giphy?<a id="3-6"/>

1.  Start a new chat with [@neb\_giphy:​matrix.org](fluffychat://@neb_giphy:​matrix.org).
2.  Search for gifs by typing: <code>!giphy KEYWORD</code>
3.  Forward the sticker by swiping the sticker message to the left and click on the ">" button.

## Bridge to other chat systems<a id="4"/>

#### What is Matrix?<a id="4-1"/>

Matrix is an open standard for interoperable, decentralised, real-time communication over IP. It can be used to power Instant Messaging, VoIP/WebRTC signalling, Internet of Things communication - or anywhere you need a standard HTTP API for publishing and subscribing to data whilst tracking the conversation history.

#### How can I enter a XMPP multi-user chat?<a id="4-2"/>

The easiest way currently is to use the bridge on matrix.org.  
Every XMPP multi-user chat has a Jabber identifier (JID) with the format: <code>chatname@chat.server.abc</code>
The chatname is the **local** part and the chat.server.abc is the **server** part. You can enter this chat by entering the Matrix public room: `#_xmpp_server_local:matrix.org` ([How can I join a public chat?](#2-2))  
For the given example this would be: `#_xmpp_chat.server.abc_chatname:matrix.org`

#### How can I enter an IRC node on Freenode?<a id="4-3"/>

If you want to enter the node `#chatname` on freenode you can just join the public chat: `#freenode_#chatname:matrix.org`  
Replace `#chatname` with the node you want to join and you are in.

#### How can I bridge a group chat with a Telegram group chat?<a id="4-4"/>

Look at the tutorial on [wayneoutthere.com](https://wayneoutthere.com/how-to-bridge-matrix-telegram/).

## Error handling<a id="5"/>

#### Why don't I receive push notifications?<a id="5-1"/>

Do you have an Ubuntu One account in the system settings?  
When you go into fluffychat -> Settings -> Notifications: Is there a device "UbuntuPhone" with the label "This device"?  
Have you tried to logout and login?  
Do you have the latest version of FluffyChat installed from the OpenStore?  
Have you tried to turn airplaine mode on and off again? Sometimes notifications are sent with a delay from the UBports push service (will be fixed soon) If you still have the problem, then please contact me at the room: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org)

#### Why can't I connect with port 8448?<a id="5-2"/>

Sorry! On port 8448 the most homeservers use a different ssl certificate, which causes an error. Currently the xmlhttprequest in QML does not allow those certificates.

#### Why can't I connect with self signed certificate?<a id="5-3"/>

The same problem... I recommend you to use a letsencrypt certificate.

## About FluffyChat<a id="6"/>

#### How is FluffyChat founded?<a id="6.1"/>

FluffyChat is funded by the community. You can support FluffyChat on [Patreon](https://www.patreon.com/krillechritzelius) or [Liberapay](https://liberapay.com/KrilleChritzelius)
