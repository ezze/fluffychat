---
layout: default
title: FAQ
lang: nl
---
# Frequently Asked Questions

*   [Account instellingen](#1)
*   [Beginnen met chatten](#2)
*   [Chat instellingen](#3)
*   [Verbind met andere chat systemen](#4)
*   [Foutafhandeling](#5)
*   [Over FluffyChat](#6)

## Account instellingen<a id="1"/>

#### Hoe stel ik mijn wachtwoord opnieuw in?<a id="1-1"/>

Je moet hiervoor eem emailadres verbonden hebben aan je account. Dat kun je doen bij Account instellingen. Als je geen emailadres gekoppeld hebt, moet je contact opnemen met beheer van je homeserver. ([Wat is een homeserver?](#1-5))  
[Klik hier om je wachtwoord te resetten](https://www.ubports.chat/#/forgot_password).

#### Hoe maak ik een nieuw account aan?<a id="1-2"/>

1.  Wanneer je al ingelogd bent in FluffyChat, ga dan naat de instellingen en tik op "Uitloggen" onderaan.
2.  Kies een gebruikersnaam en zorg ervoor dat "Maak een account aan" is aangevinkt.
3.  Als je een account wil maken op een andere homeserver dan de standaard (ubports.chat), ga dan naar het menu linksboven en wijzig de homeserver. ([Wat is een homeserver?](#1-5))
4.  Ga naar "Inloggen" en kies een nieuw wachtwoord.

#### Hoe kan ik op mijn oude account inloggen?<a id="1-3"/>

1.  Wanneer je al ingelogd bent in FluffyChat, ga dan naat de instellingen en tik op "Uitloggen" onderaan.
2.  Voer de gebruikersnaam of je Matrix ID van je oude account. ([Wat is een Matrix ID?](#1-4)) Als je je gebruikersnaam of Matrix ID niet herinnert, maar wel het telefoonummer dat gekoppeld is aan je account, dan kun je een willekeurige gebruikersnaam invoeren en het correcte telefoonnummer in de volgende stap. De gebruikersnaam zal dan automatisch gevonden worden.
3.  (Optioneel) Voer het telefoonnummer van je oude account in.
4.  Wanneer je oude account niet op de standaard homeserver (ubports.chat)is, ga dan naar het menu linksboven en wijzig de homeserver. ([Wat is een homeserver?](#1-5))
5.  Let op dat "Maak een account" **niet** is aangevinkt.
6.  Ga naar "Inloggen" en voer je wachtwoord in. ([Wachtwoord vergeten?](#1-1))

#### Wat is een Matrix ID?<a id="1-4"/>

Je Matrix ID is je unieke indificatie in het Matrix netwerk. Het is een combinatie van je gebruikerenaam en je homeserver. ([Wat is een homeserver?](#1-5))  
De samenstelling van een Matrix ID is simpel: <code>@username:homeserver</code>. Als bijvoorbeeld je gebruikersnaam "piet" is, en je homeserver is "homeserver.abc", dan is je Matrix ID: <code>@piet:homeserver.abc</code>

#### What is a homeserver?<a id="1-5"/>

Matrix is een gefederaliseerd netwerk van homeservers. Wat betekent dit? Er is geen centrale "FluffyChat server" maar vele homeservers die je kunt gebruiken. Je bent vrij om zelf een homeserver te kiezen. Net als bij email kunnen gebruikers van alle homeservers communiceren met elkaar. Er is een standaard homeserver op FluffyChat, namelijk "https://ubports.chat". Je kunt ook je eigen homeserver hosten. [Klik hier voor een handleiding hoe daarmee te beginnen](https://matrix.org/docs/guides/installing-synapse).

#### Wat is een identity server?<a id="1-6"/>

Gebruikers in Matrix worden intern geidentificeerd via hun Matrix ID. Echter, namespace ID's van derde partijen (3PID) zoals email adressen of telefoonnummers worden naar buiten toe gebruikt om Matrix gebruikers te identificeren, in eerste plaats voor uitnodigingen. een Matrix "Identiteit" beschrijft zowel de gebruiker ID en eventuele andere bestaande IDs van namespaces van derde partijen gelinkt aan zijn/haar account.  
Matrix gebruikers kunnen derde partij IDs (3PIDs) linken aan hun eigen gebruikers ID. Het linken van 3PIDs creëert een mapping van een 3PID naar een gebruikers ID. Deze mapping kan dan gebruikt worden door Matrix gebruikers om de MXIDs van hun contacten te vinden. Om ervoor te zorgen dat de mapping van 3PID naar gebruikers ID klopt, is de bedoeling om een wereldwijd gefederaliseerd cluster van vertrouwde "Identity Servers" (IS) te gebruiken voor verificatie van 3PID's en om de mappings te onderhouden en repliceren. Gebruik van een IS is niet vereist om een client applicatie deel te laten uitmaken van het Matrix ecosysteem. Echter, zonder dat zullen clients niet in staat zijn om gebruiker IDs op te zoeken middels 3PIDs.

## Beginnen met chatten<a id="2"/>

#### Hoe start ik een nieuwe chat?<a id="2-1"/>

1.  Klik op "Chat toevoegen" op de start pagina of veeg van onderaf omhoog op telefoons.
2.  Kies de contacten die je wil toevoegen en klik op "Start een nieuwe chat". Een alternatief is om een groep te creeren en contacten uit te nodigen.
3.  Als je een contact niet kunt vinden, kun je die [toevoegen d.m.v. hun telefoonnummer](#2-4) of door hun Matrix ID in te voeren in het zoek veld. ([Wat is een Matrix ID?](#1-4))

#### Hoe kan ik deelnemen aan een publieke chat?<a id="2-2"/>

een publieke chat heeft 1 of meer publieke adressen die we aliassen noemen. Die beginnen altijd met een '#' en eindigen met ':homeserver.abc'. Bij voorbeeld: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org). Je hoeft alleen op de de link te klikken om deel te nemen aan de chat.
Ook kun je handmatig een alias invullen als je gaat naar "Start een nieuwe chat" -> "Publieke chats".

#### Hoe kan ik deelnemen aan een gemeenschap?<a id="2-3"/>

een gemeenschaps chat heeft 1 of meer publieke adressen die we aliassen noemen. Die beginnen altijd met een '+' en eindigen met ':homeserver.abc'. Bij voorbeeld: [+ubports\_community:matrix.org](fluffychat://+ubports_community:matrix.org). Je hoeft alleen op de de link te klikken om alle aan deze gemeenschap geassocieerde chats te zien. Voor meer mogelijkheden, ga naar de [desktop web app](https://www.ubports.chat).

#### Hoe kan ik contacten toevoegen d.m.v. hun telefoonnummer?<a id="2-4"/>

1.  Klik op "Start chatten" in de startpagina of veeg van onderaf omhoog op telefoons.
2.  Klik op "Contacten toevoegen" bovenaan rechts.
3.  Klik op "Importeer vanuit adresboek" en kies je adresboek app.
4.  Kies het contact dat je wil toevoegen of selecteer alle contacten en bevestig.
5.  FluffyChat zal die contacten gaan zoeken op de identity server. ([Wat is een identity server?](#1-6))

#### Welke /commando's zijn er?<a id="2-5"/>

*   <code>/me</code> (Stuurt msgtype: m.emote) Laat een actie zien.
*   <code>/whisper</code> (Stuurt msgtype: m.fluffychat.whisper) De bericht tekst wordt heel klein
*   <code>/roar</code> (Stuurt msgtype: m.fluffychat.roar) De bericht tekst wordt heel groot, vet en in hoofdletters
*   <code>/shrug</code> Plaatst ¯\\(ツ)/¯ aan het begin van een bericht

## Chat instellingen<a id="3"/>

#### Hoe kan ik een gebruiker verwijderen of verbannen uit een chat?<a id="3-1"/>

Dit vereist het recht om een gebruiker te verwijderen of verbannen uit een chat.

1.  Ga naar de chat.
2.  Ga naar "Chat details" in het menu rechtsboven.
3.  Zoek de gebruiker die je wil verwijderen of verbannen and veeg dat lijst-onderdeel naar rechts.
4.  Tik op de verwijder of verban knop en bevestig.

#### Hoe kan ik de rechten van een gebruiker aanpassen in een chat?<a id="3-2"/>

Dit vereist het recht om rechten van gebruikers aan te passen.

1.  Ga naar de chat.
2.  Ga naar "Chat details" in het menu rechtsboven.
3.  Zoek de gebruiker waarvan je de rechten wil aanpassen and veeg dat lijst-onderdeel naar rechts.
4.  Tik op de gewenste gebruikersrechten knop en bevestig.

#### Hoe kan ik het chatonderwerp en omschrijving aanpassen?<a id="3-3"/>

Dit vereist het recht om het chatonderwerp en omschrijving aan te passen.

1.  Ga naar de chat.
2.  Ga naar "Chat details" in het menu rechtsboven.
3.  Tik op de edit knop rechtsboven en voer het gewenste chatonderwerp en/of omschrijving in.

#### Hoe kan ik de privacy settings van de chat aanpassen?<a id="3-4"/>

Dit vereist het recht om privacy instellingen aan te passen.

1.  Ga naar de chat.
2.  Ga naar "Chat details" in het menu rechtsboven.
3.  Gan naar "Geavanceerde instellingen"
4.  Vink de gewenste optie aan of uit en pas de gebruikers rechten optie aan.

#### Wat zijn chat aliassen en hoe kan ik ze aanpassen?<a id="3-5"/>

Chat aliassen zijn publieke chat adressen die gebruikt kunnen worden om tot chat toe te treden. Je hebt rechten nodig om dit aan te passen.

1.  Ga naar de chat.
2.  Ga naar "Chat details" in het menu rechtsboven.
3.  Ga naar "Privacy and beveiliging"
4.  Vink de gewenste optie aan of uit en pas de gebruikers rechten optie aan.

#### Hoe kan ik bewegende stickers met Giphy sturen?<a id="3-6"/>

1.  Start een nieuwe chat met [@neb\_giphy:​matrix.org](fluffychat://@neb_giphy:​matrix.org).
2.  Zoek de gifs door deze code te typen: <code>!giphy KEYWORD</code>
3.  Stuur de sticker door, door het naar links vegen van het stickerbericht en dan op de ">" knop te tikken.

## Verbind met andere chat systemen<a id="4"/>

#### Wat is Matrix?<a id="4-1"/>

Matrix is een open standard voor samenwerkende, gedecentraliseerde, real-time communicatie over IP. Het kan gebruikt worden voor Instant Messaging, VoIP/WebRTC communicatie, Internet of Things communicatie - of iets anders waarbij een standaard HTTP API nodig is voor het publiceren and en ontvangen van data waarbij the conversatie geschiedenis beschikbaar blijft.

#### Hoe kan ik een XMPP multi-user chat invoeren?<a id="4-2"/>

De makkelijkste manier momenteel is om de bridge te gebruiken op matrix.org.  
Elke XMPP multi-user chat heeft een Jabber identificatie (JID) in de samenstelling: <code>chatname@chat.server.abc</code>
De chatnaam is het **local** deel en de chat.server.abc is het **server** deel. Je kunt deze chat ingeven door de Matrix publieke ruimte in te voeren: `#_xmpp_server_local:matrix.org` ([Hoe kan ik deelnemen aan een publieke chat?](#2-2))  
Voor het gegeven voorbeeld zou dit zijn: `#_xmpp_chat.server.abc_chatname:matrix.org`

#### Hoe kan ik een IRC node op Freenode toevoegen?<a id="4-3"/>

Als je de node `#chatname` op freenode wil toevoegen, kun je gewoon deelnemen aan de publieke chat: `#freenode_#chatnaam:matrix.org`  
verwissel `#chatnaam` met node waarin je wilt deelnemen en je bent binnen.

#### Hoe kan ik een groeps chat met een Telegram groeps chat verbinden?<a id="4-4"/>

Lees de handleiding op [wayneoutthere.com](https://wayneoutthere.com/how-to-bridge-matrix-telegram/).

## Foutafhandeling<a id="5"/>

#### Waarom ontvang ik geen push notificaties?<a id="5-1"/>

Heb je een Ubuntu One account in je systeeminstellingen?  
Als je in fluffychat gaat naar Instellingen -> Meldingen -> Doelstellingen: Is daar een apparaat met het label "This device"?  
Heb je geprobeerd in- en uit te loggen?  
Heb je de laatste versie van FluffyChat geinstalleerd van de OpenStore?  
Heb je geprobeerd om vliegtuigstand aan- en weer uit te zetten? Soms worden notificaties met een vertraging vanaf the UBports push service gestuurd (zal spoedig verholpen zijn) Als je dan nog steeds problemen hebt, neem dan a.u.b. contact met mij op in de ruimte: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org)

#### Waarom kan ik niet verbinden met poort 8448?<a id="5-2"/>

Sorry! Op poort 8448 gebruiken de meeste homeservers een ander ssl certificaat, die een fout veroorzaakt. Op dit moment staat het xmlhttprequest in QML deze certificaten niet toe.

#### Waarom kan ik niet verbinden met een self signed certificaaat?<a id="5-3"/>

Het zelfde probleem... Ik raad je aan een letsencrypt certificaat te gebruiken.

## Over FluffyChat<a id="6"/>

#### Hoe wordt FluffyChat betaald?<a id="6.1"/>

FluffyChat wordt gefinancierd door de gemeenschap. Je kunt FluffyChat ondersteunen op [Patreon](https://www.patreon.com/krillechritzelius) of [Liberapay](https://liberapay.com/KrilleChritzelius)
