---
layout: default
title: FAQ
lang: de
---
# Häufig gestellte Fragen

*   [Konto Einstellungen](#1)
*   [Chat starten](#2)
*   [Einstellungen im Chat](#3)
*   [Verbindung zu anderen Chatsystemen](#4)
*   [Fehlerbehandlung](#5)
*   [Über FluffyChat](#6)

## Konto Einstellungen <a id="1"/>

#### Wie kann ich mein Passwort zurücksetzen?<a id="1-1"/>

Du musst dein Konto mit deiner E-Mail-Adresse verbinden. Das machst du in den Einstellungen. Wenn du keine E-Mail-Adresse hast, musst du dich an den Support deines Homeservers wenden. ([Was ist der Homeserver?](#1-5))  
[Klicke hier um dein Passwort zurück zu setzten](https://www.ubports.chat/#/forgot_password).

#### Wie erstelle ich ein neues Konto?<a id="1-2"/>

1.  Wenn du bereits in FluffyChat angemeldet bist, gehe zu den Einstellungen und melde dich ab.
2.  Wähle einen neuen Benutzernamen und klicke auf "Neues Konto erstellen"
3.  Wenn du ein Konto auf einem anderen Homeserver als dem Standardkonto (ubports.chat) erstellen möchtest, wechsel in das Menü oben links und ändere den Homeserver. ([Was ist der Homeserver?](#1-5))
4.  Dann gehe auf "Einloggen" und erstelle ein neues Passwort.

#### Wie kann ich mich in mein altes Konto einloggen?<a id="1-3"/>

1. Wenn du breits in FluffyChat eingeloggt bist gehe in die Einstellungen und klicke auf "Ausloggen".
2.   Gib deinen Benutzernamen oder die Matrix ID von deinem alten Account ein. ([Was ist die Matrix ID?](#1f-4)) Wenn du deinen Benutzernamen oder deine Matrix ID nicht mehr weißt, aber dafür die Handynummer die mit dem Accout Verbunden ist, kannst du einfach irgendeinen Benutzernamen und im nächsten Schritt die richtige Handynummer eingeben. Dann wird dein Benutzername automatisch gefunden.
3.  (Optional) Gib die Handynummer von deinem alten Account ein.
4.   Wenn dein alter Account nicht auf deinem Standart-Homeserver ( ubports.chat) ist, klicke auf das Menü oben links und ändere den Homeserver. ([Was ist ein  Homeserver?](#1-5))
5.   Vergewissere dich, dass "Konto erstellen" **nicht** Markiert ist.
6. Klicke auf "Einloggen" und gib dein Passowrt ein. ([Passwort vergessen?](#1-1))

#### Was ist eine  MatrixID?<a id="1-4"/>

 Deine Matrix ID ist deine eingene Identifizierung im Matrix Netzwerk. Es ist eine Kombination aus deinem Benutzernamen und deinem Homeserver. ([Was ist ein Homeserver?](#1-5))  
 Das Format einer Matrix ID ist einfach: @benutzername:homeserver. Zum Beispiel: Wenn dein Benutzername "Alice" ist und dein Homeserver "homeserver.abc" heißt, lautet deine Matrix ID "alice:homeserver.abc.

#### Was ist ein Homeserver?<a id="1-5"/>

 Matrix ist ein fördiertes Netzwerk von Homeservern. Was bedeutet das? Es gibt keinen zeltralisierten "FluffyChat-Server", es gibt viele verschiedene Homeserver die du nutzen kannst. Du kannst also den Homeserver wählen den du möchtest.Genau wie bei der Email könnte alle Nutzer von allen HOmeservern miteinander Kommunizieren.Auf FluffyChat gibt es einen Standard-Homeserver mit dem Namen "https://ubports.chat". Du kannst deinen eigenen Homeserver hosten. [Klicke hier um eine Aleitung zum Starten zu erhalten.](https://matrix.org/docs/guides/installing-synapse).

#### Was ist ein Identity Server ?<a id="1-6"/>

Benutzer in der Matrix werden intern über ihre Matix ID identifiziert. Vorhandene Namespaces mit Drittanbieter-IDs (3PID) wie E-Mail-Adressen oder Telefonnummern sollten jedoch zur Identifizierung von Matrix-Benutzern zumindest für Einladungszwecke öffentlich verwendet werden.Eine Matrix "Identity" beschreibt sowohl die Benutzer-ID als auch alle anderen vorhandenen IDs von mit ihrem Konto verknüpften Namespaces von Drittanbietern. 
Matrix-Benutzer können Drittanbieter-IDs (3PIDs) mit ihrer Benutzer-ID verknüpfen.Durch das Verknüpfen von 3PIDs wird eine Zuordnung von einer 3PID zu einer Benutzer-ID erstellt.Diese Zuordnung kann dann von Matrix-Benutzern verwendet werden, um die MXIDs ihrer Kontakte zu ermitteln. Um sicherzustellen, dass die Zuordnung von 3PID zu Benutzer-ID echt ist, soll ein global eingebundener Cluster von vertrauenswürdigen "Identity Servern" (IS) verwendet werden, um die 3PID zu überprüfen und die Zuordnungen beizubehalten und zu replizieren.Die Verwendung eines IS ist nicht erforderlich, damit eine Clientanwendung Teil des Matrix-Ökosystems ist.Ohne einen Client können Benutzer-IDs jedoch nicht mit 3PIDs gesucht werden. 
## Einen neuen Chat starten<a id="2"/>

#### Wie kann ich einen neuen Chat starten? <a id="2.1"/>

1. Klicke auf  der Startseite auf "Chat hinzufügen" oder wische bei deinem Handy von unten nach oben. 
2.   Wähle den Kontakt aus mit welchem du Chatten möchtest und klicke auf "Neuen Chat starten" Alternativ kannst du auf eine neue Gruppe erstellen und Kontakte einladen.
3.  Falls du einen Kontakt nicht finden solltest kannst du diesen  [über seine Nummer hinzufügen] (#2-4)oder ihre Matrix ID in die Suchleiste iengeben.([Was ist eine Matrix ID?](#1-4))

####  Wie kann ich einem öffentlichen Chat beitreten?<a id="2.2"/>

 Ein öffentlicher Chat hat ein oder mehrere öffentliche Adressen die sich Aliases nennen. Sie fangen immer mit einem "#" und hören mit einem ":homeserver.abc"auf. Zum Beispiel:[#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org). Klicke einfach auf den Link um dem Chat beizutreten.Du kannst den Alias manuell eingeben, indem du auf "Neuen Chat beginnen" gehst. 

#### Wie kann ich einer Community beitreten?<a id="2.3"/>

 Eine Commuity hat eine oder mehrere Adressen die sich Aliasses nennen. Sie beginnen inner mit einem '+'und enden mit ':homeserver.abc'. Zum Beispiel:[+ubports\_community:matrix.org](fluffychat://+ubports_community:matrix.org). Klicke einfach auf den Link, um alle mit dieser Community verbundenen Chats anzuzeigen.Für noch mehr Optionen Benutze den beigefügten Link [desktop web app](https://www.ubports.chat).

#### Wie kann ich Kontakte über ihre Handynummer hinzufügen?<a id="2.4"/>

1. Klicke auf den "Chat starten" button auf der Startseite oder wische auf deinem Handy von unten nach oben.
2. Klicke oben rechts auf der Schaltfläche auf "Kontakt hinzufügen".
3. Klicke auf "Import aus Adressbuch" und wähle deine Adressbuch-App aus.
4.  Select the contact you want to add or select all contacts and confirm.
5. FluffyChat sucht im Identitätsserver nach diesen Kontakten. ([Was ist ein Identitätsserver?](#1-6))

#### Welche Befehle stehen zur Verfügung?<a id="2.5"/>

*   `/me` (Will send msgtype: m.emote) Zeigt eine Aktion an.
*   `/whisper` (Will send msgtype: m.fluffychat.whisper) Der Nachrichtentext wird sehr klein sein.
*   `/roar` (Will send msgtype: m.fluffychat.roar) Der Nachrichtentext ist sehr groß, fett und in Großbuchstaben.
*   `/shrug` Puts ¯\\(ツ)/¯ Am Anfang der Nachricht.

## Chat Einstellungen<a id="3"/>

#### Wie kann ich einen Nutzer aus dem Chat werfen oder sperren?<a id="3.1"/>

Du benötigst die Berechtigung, um einen Benutzer aus einem Chat zu sperren.

1. Gehe zu dem Chat. 
2. Klicke oben rechts im Menü auf "Chat Details".
3.  Suche den Benutzer, den du Rauswefgen oder sperren möchten, und ziehe den Benutzerlisteneintrag nach rechts.
4.  Klicke auf den "rauswerfen" oder "sperren" button und bestätige diese Eingabe.

#### Wie kann ich die Benutzerberechtigungen in einem Chat ändern?<a id="3.2"/>

Du brauchst die Berechtigung, um die Benutzerberechtigungen zu ändern.

1.  Gehe auf den Chat.
2.  Klicke  oben rechts im Menü auf "Chat Details". Go to "Chat details" in the top right menu
3.  Gib den Nutzer an, den du rauswerfen oder sperren möchtest und ziehe den Nutzer nach links. 
4.  Klicke  auf die gewünschte Benutzerberechtigungsschaltfläche und bestätige 

#### Wie kann ich das Chat- Thema und die Beschreibung ändern?<a id="3.3"/>

Du brauchst die Berechtigung um das Thema und die Beschreibung zu ändern.

1.   Kliche auf den Chat.
2.  Gehe dann rechts oben im Menü auf "Chat Details".
3.  Klicken Sie oben rechts auf die Schaltfläche "Bearbeiten" und geben Sie das gewünschte Chat-Thema und / oder die Beschreibung ein.

#### Wie kann ich die Datenschutzeinstellungen bearbeiten?<a id="3.4"/>

 Du brauchst eine Erlaubnis um die Datenschutzeinstellungen zu bearbeiten.
 
1.  Gehe auf den Chat.
2.  Klicke dann oben rechts im Menü auf "Chat Details" 
3.  Gehe zu "Erweiterte Einstellungen"
4.  Aktiviere oder deaktiviere die gewünschten Optionen und bearbeite die Benutzerberechtigungsoptionen.

#### Was sind Chat-Aliasses und wie kann ich diese bearbeiten?<a id="3.5"/>

Aliasnamen sind öffentliche Chat-Adressen, an denen du teilnehmen kannst. Du benötigst die Chatberechtigungen, um sie zu ändern.

1.   Gehe auf den Chat. 
2.   Klicke oben rechts im Menü auf "Chat Details". 
3.   Gehe auf "privatsphäre und Sicherheit" 
4.   Aktiviere oder deaktiviere die gewünschten Optionen und bearbeite die Benutzerberechtigungsoptionen. 

#### Wie kann ich animierte Sticker mit Giphy senden?<a id="3.6"/>

1.  Beginne einen neuen Chat mit  [@neb\_giphy:​matrix.org](fluffychat://@neb_giphy:​matrix.org).
2.  Suche nach GIFs durch Eingabe: '!giphy KEYWORD'
3.  Leite den Sticker weiter, indem du die Stickernachricht nach links streichst, und klicke auf die Schaltfläche ">".

## Brücke zu anderen Chat-Systemen<a id="4"/>

#### Was ist Matrix?<a id="4.1"/>

Matrix ist ein offener Standard für interoperable, dezentrale Echtzeitkommunikation über IP. Es kann verwendet werden, um Instant Messaging, VoIP / WebRTC-Signalisierung und Internet of Things-Kommunikation zu betreiben - oder überall, wo Sie eine Standard-HTTP-API zum Veröffentlichen und Abonnieren von Daten benötigen, während Sie den Konversationsverlauf verfolgen.

#### Wie kann ich einem XMPP-Gruppenchat beitreten?<a id="4.2"/>

Der einfachste Weg ist derzeit die Verwendung der Bridge auf matrix.org.
Jeder XMPP-Chat für mehrere Benutzer verfügt über eine Jabber-ID (JID) mit dem Format: `chatname @ chat.server.abc` 
Der Chatname ist der ** lokale ** Teil und der Chat.server.abc ist der ** Server ** Teil. Sie können diesen Chat betreten, indem Sie den Matrix Public Room betreten: `#_xmpp_server_local: matrix.org` ([Wie kann ich einem öffentlichen Chat beitreten?] (# 2-2)) 
Für das gegebene Beispiel wäre das: `#_xmpp_chat.server.abc_chatname:matrix.org`

#### Wie kann ich einem IRC-Knoten in Freenode beitreten?<a id="4.3"/>

Wenn du den Knoten "#chatname" in Freenode eingeben möchtest, können Sie einfach dem öffentlichen Chat beitreten: `#freenode_#chatname:matrix.org`  
Ersetze den "#chatname" durch den Knoten, dem du beitreten möchtest, und du bist dabei.

#### Wie kann ich einen Gruppenchat mit einem Telegrammgruppenchat koppeln?<a id="4.4"/>

Schau dir die Anleitung unter [wayneoutthere.com](https://wayneoutthere.com/how-to-bridge-matrix-telegram/) an.

## Fehlerbehandlung<a id="5"/>

#### Warum erhalte ich keine Push-Benachrichtigungen?<a id="5.1"/>

Hast du eine Ubuntu One-Konto in deinen Systemeinstellungen?
Wenn du in Fluffychat gehst -> Einstellungen -> Benachrichtigungen: Gibt es ein Gerät "UbuntuPhone" mit der Bezeichnung "Dieses Gerät"?
Hast du versucht dich nochmal "auszuloggen" und wieder "einzuloggen"?  
Hast du die neuste Versoin von Fluffyschat von dem OpenStore installiert?
Hast du versucht den Flugmodus an und aus zu stellen? Have you tried to turn airplaine mode on and off again? Manchmal werden Benachrichtigungen mit Verzögerung vom UBports-Push-Dienst gesendet (wird in Kürze behoben). Wenn du das Problem immer noch hast, wende dich bitte an mich unter: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org)

#### Wieso kann ich mich nicht mit dem Port 8448 verbinden?<a id="5.2"/>

Es tut uns leid! Auf dem  Port 8448 verwenden die meisten Homeserver ein anderes SSL-Zertifikat, was zu einem Fehler führt. Derzeit erlaubt das xmlhttprequest in QML diese Zertifikate nicht.
###Warum kann ich keine Verbindung mit einem selbstsignierten Zertifikat herstellen?<a id="5.3"/>

Da ist das gleiche Problem ... Ich empfehle dir, ein Letsencrypt-Zertifikat zu verwenden.
## Über FluffyChat<a id="6"/>

#### Wie wird FluffyChat finanziert?<a id="6.1"/>

FluffyChat wird von der Community finanziert. Du kannst FluffyChat unterstützen unter [Patreon](https://www.patreon.com/krillechritzelius) oder unter [Liberapay](https://liberapay.com/KrilleChritzelius).
