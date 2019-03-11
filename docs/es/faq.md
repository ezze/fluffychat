---
layout: default
title: FAQ
lang: es
---
# Preguntas frecuentes

*   [Configuración de la cuenta](#1)
*   [Comenzar a chatear](#2)
*   [Configuración del chat](#3)
*   [Pasarela a otros sistemas de chat](#4)
*   [Gestión de errores](#5)
*   [Acerca de FluffyChat](#6)

## Configuración de la cuenta<a id="1"/>

#### ¿Cómo puedo restablecer mi contraseña?<a id="1-1"/>

Debe conectar una dirección de correo electrónico a su cuenta. Se puede hacer en la configuración de la cuenta. Si no tiene conectada una dirección de correo electrónico, tiene que contactar con el soporte de su «homeserver» (servidor de datos).
 ([¿Qué es un «homeserver» (servidor de datos)?](#1-5))  
[Pulse aquí para restablecer su contraseña](https://www.ubports.chat/#/forgot_password).

#### ¿Cómo puedo crear una nueva cuenta?<a id="1-2"/>

1.  Si ya ha iniciado sesión en FluffyChat, vaya a configuración y pulse en «cerrar sesión» en la parte inferior.
2.  Elija un nuevo nombre de usuario y compruebe que está seleccionado «crear una cuenta».
3.  Si quiere crear una cuenta en un «homeserver» (servidor de datos) distinto al predeterminado (ubports.chat), vaya al menú superior de la izquierda y cambie el «homeserver» (servidor de datos). ([¿Qué es un «homeserver» (servidor de datos)?](#1-5))
4.  Vaya a «iniciar sesión» y elija una nueva contraseña.

#### ¿Cómo puedo iniciar sesión en mi cuenta antigua?<a id="1-3"/>

1.  Si ya ha iniciado sesión en FluffyChat, vaya a configuración y pulse en «cerrar sesión» en la parte inferior.
2.  Introduzca el nombre de usuario o la identificación («ID») de Matrix de su cuenta antigua. ([¿Qué es una identificación («ID») de Matrix?](#1-4)) Si no recuerda su nombre de usuario o su identificación («ID») de Matrix pero recuerda el número de teléfono conectado con su cuenta, entonces puede introducir cualquier nombr de usuario y el número de teléfono correcto en el siguiente paso. El nombre de usuario será localizado automáticamente.
3.  (Opcional) Introduzca el número de teléfono de su antigua cuenta.
4.  Si su cuenta antigua no está en el «homeserver» (servidor de datos) predeterminado (ubports.chat), vaya al menú superior de la izquierda y cambie el «homeserver» (servidor de datos). ([¿Qué es un «homeserver» (servidor de datos)?](#1-5))
5.  Asegúrese de que «crear una cuenta» **no** está marcado.
6.  Vaya a «iniciar sesión» e Introduzca su contraseña. ([¿Contraseña olvidada?](#1-1))

#### ¿Qué es una identificación («ID») de Matrix?<a id="1-4"/>

Su «ID» de Matrix es su identificador único en la red de Matrix. Es una combinación de su nombre de usuario y de su «homeserver» (servidor de datos). ([¿Qué es un «homeserver» (servidor de datos)?](#1-5))  
El formato de una identificación («ID») de Matrix es sencillo: <code>@nombredeusuario:homeserver</code>. Por ejemplo, si su nombre de usuario es «alicia» y su «homeserver» (servidor de datos) es «homeserver.abc», entonces su («ID») de Matrix es: <code>@alicia:homeserver.abc</code>

#### ¿Qué es un «homeserver» (servidor de datos)?<a id="1-5"/>

Matrix es una red federada de «homeservers» (servidores de datos). ¿Qué significa esto? No hay un «servidor de FluffyChat» centralizado pero existen muchos «homeservers» (servidores de datos) que puede usar. Es libre para elegir el que quiera. Al igual que ocurre con el correo electrónico, todos los servidores se comunican entre ellos. Existe un «homeserver» (servidor de datos) predeterminado en FluffyChat llamado «https://ubports.chat». También puede alojar su propio servidor. [Pulsar aquí para la guía de como comenzar](https://matrix.org/docs/guides/installing-synapse).

#### ¿Qué es un servidor de identidad?<a id="1-6"/>

Los usuarios en Matrix son identificados internamente vía un «ID» de Matrix. Sin embargo, identificadores actuales de terceras partes («3PID») como las direcciones de correo electrónico o los números de teléfono deberían usarse públicamente para identificar a los usuarios de Matrix, al menos para las invitaciones. Una «identidad» de Matrix describe tanto el «ID» del usuario como cualquier otros «IDs» de terceras partes enlazadas a sus cuentas.  
Los usuarios de Matrix pueden enlazar «IDs» de terceras partes («3PIDs») a sus «ID» de usuario. Enlazando «3PIDs» se crea un mapeo desde un «3PID» a un «ID» de usuario. Este mapeo puede luego ser usado por los usuarios de Matrix para descubrir los «MXIDs» de sus contactos. Para asegurar que el mapeo desde el «3PID» a un «ID» de usuario es genuino, la intención es que haya un grupo globalmente federado de servidores de identidad («IS») de confianza para usarlo para verificar el «3PID» y continuar y replicar los mapeos. No se necesita el uso de un «IS» para que una aplicación cliente sea parte del ecosistema de Matrix. Sin embargo, sin un cliente no será capaz de buscar «IDs» de usuario usando «3PIDs».

## Comenzar a chatear<a id="2"/>

#### ¿Cómo puedo comenzar un nuevo chat?<a id="2-1"/>

1.  Vaya al botón "+" en la página de inicio o deslice desde abajo en el dispositivo.
2.  Elija los contactos que quiere invitar a su nuevo chat. No es necesario invitar a alguno.
3.  Si no encuentra un contacto, puede [añadirlo por el número de teléfono](#2-4) o introducir su «ID» de Matrix en el campo de búsqueda. (¿Qué es una identificación («ID») de Matrix?](#1-4))
4.  Vaya a «crear chat»
5.  Si desea crear un chat directo con un contacto, simplemente seleccione un contacto o toque el avatar y vaya a «Iniciar chat directo».

#### ¿Cómo puedo unirme a un chat público?<a id="2-2"/>

Un chat público tiene una o más direcciones públicas llamadas «alias». Siempre empiezan con «#» y terminan con «:homeserver.abc». Por ejemplo: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org). Solo pulse en el enlace para participar en el chat o introduzca un alias en el campo de búsqueda en la página de inicio de FluffyChat.

#### ¿Cómo puedo unirme a una comunidad?<a id="2-3"/>

Una comunidad pública tiene una o más direcciones públicas llamadas «alias». Siempre empiezan con «+» y terminan con «:homeserver.abc». Por ejemplo: [+ubports\_community:matrix.org](fluffychat://+ubports_community:matrix.org). Solo pulse en el enlace para ver todos los chats asociados con una comunidad. Para más detalles, visite la [aplicación web de escritorio](https://www.ubports.chat).

#### ¿Cómo puedo añadir contactos por su número de teléfono?<a id="2-4"/>

1.  Vaya al botón «+» en la página de inicio o deslice desde abajo en el dispositivo.
2.  Vaya a «añadir contacto» en la parte superior de la izquierda.
3.  Elija su aplicación de agenda.
4.  Seleccione el contacto que desee añadir o seleccione todos los contactos y confirme.
5.  FluffyChat buscará esos contactos en el servidor de identidad. ([¿Qué es un servidor de identidad?](#1-6))

#### ¿Qué «/órdenes» están disponibles?<a id="2-5"/>

*   <code>/me</code> (Enviará «msgtype: m.emote») Muestra una acción.
*   <code>/whisper</code> (Enviará «msgtype: m.fluffychat.whisper») El texto del mensaje será muy pequeño
*   <code>/roar</code> (Enviará «msgtype: m.fluffychat.roar») El texto del mensaje será muy grande, en negrita y mayúsculas
*   <code>/shrug</code> Coloca «¯\\(ツ)/¯» al inicio del mensaje

## Configuración del chat<a id="3"/>

#### ¿Cómo puedo expulsar o vetar a un usuario en el chat?<a id="3-1"/>

Necesita tener los permisos necesarios para expulsar («kick») o vetar («ban») a un usuario en un chat.

1.  Vaya al chat
2.  Vaya a «información del chat» en el menú superior a la derecha
3.  Encuentre al usuario que quiere expulsar o vetar y deslice el elemento de la lista de usuarios hacia la derecha.
4.  Pulse en el botón de expulsar o vetar y confirme

#### ¿Cómo puedo cambiar los permisos de usuario en un chat?<a id="3-2"/>

Necesita el permiso para cambiar los permisos de los usuarios.

1.  Vaya al chat
2.  Vaya a «información del chat» en el menú superior a la derecha
3.  Encuentre al usuario que quiere expulsar o vetar y deslice el elemento de la lista de usuarios hacia la izquierda.
4.  Pulse en el botón de permiso de usuario que desee y confirme

#### ¿Cómo puedo cambiar el tema del chat y la descripción?<a id="3-3"/>

Necesita el permiso para cambiar el tema del chat y la descripción.

1.  Vaya al chat
2.  Vaya a «información del chat» en el menú superior a la derecha
3.  Pulse en el botón «editar» superior de la derecha e introduzca el tema y/o descripción que desee

#### ¿Cómo puedo editar la configuración de privacidad del chat?<a id="3-4"/>

Necesita el permiso para editar la configuración de privacidad del chat.

1.  Vaya al chat
2.  Vaya a «información del chat» en el menú superior a la derecha
3.  Vaya a «privacidad y seguridad»
4.  Active o desactive las opciones que desee y edite las opciones de permisos de usuario

#### ¿Cuáles son los alias del chat y como puedo editarlos?<a id="3-5"/>

Los alias de un chat son las direcciones de un chat público que se pueden usar para unirse a un chat. Necesita el permiso del chat para cambiarlos.

1.  Vaya al chat
2.  Vaya a «información del chat» en el menú superior a la derecha
3.  Vaya a «privacidad y seguridad»
4.  Active o desactive las opciones que desee y edite las opciones de permisos de usuario

#### ¿Cómo puedo enviar pegatinas animadas con Giphy?<a id="3-6"/>

1.  Comience un nuevo chat con [@neb\_giphy:​matrix.org](fluffychat://@neb_giphy:​matrix.org).
2.  Busques gifs tecleando: «!giphy PALABRACLAVE»
3.  Añada una pegatina animada pulsando en ella y añádala a su colección de pegatinas local pulsando en el signo «+» en la zona superior derecha.

## Pasarela a otros sistemas de chat<a id="4"/>

#### ¿Qué es Matrix?<a id="4-1"/>

Matrix es un estándar abierto, interoperable y descentralizado para la comunicación en tiempo real sobre IP. Se puede usar para mensajería instantánea, voz sobre IP («VoIP/WebRTC»), comunicación de «internet de las cosas» o donde quiera que necesite una API estándar HTTP para publicar y suscribir datos, a la vez que mantiene el histórico de la conversación.

#### ¿Cómo puedo unirme a un chat multi-usuario de XMPP?<a id="4-2"/>

La manera más sencilla actual es usar la pasarela existente en matrix.org.  
Cada chat multi-usuario de XMPP tiene un identificador de Jabber («JID») con el formato: <code>chatname@chat.server.abc</code>  
El nombre de chat es la parte **local** y «chat.server.abc» es la parte del **servidor**. Puede unirse a este chat entrando en la sala pública de Matrix: `#_xmpp_server_local:matrix.org` ([¿Cómo puedo unirme a un chat público?](#2-2))  
Para el ejemplo dado sería: `#_xmpp_chat.server.abc_chatname:matrix.org`

#### ¿Cómo puedo entrar en un nodo de IRC en Freenode?<a id="4-3"/>

Si desea entrar al nodo `#chatname` en freenode puede unirse al chat público: `#freenode_#chatname:matrix.org`  
Sustituya `#chatname` con el nodo que desee y en el que esté.

#### ¿Cómo puedo hacer una pasarela entre un chat de grupo y un grupo de Telegram?<a id="4-4"/>

Vea el tutorial en [wayneoutthere.com](https://wayneoutthere.com/how-to-bridge-matrix-telegram/).

## Gestión de errores<a id="5"/>

#### ¿Por qué no recibo notificaciones?<a id="5-1"/>

¿Tiene una cuenta de Ubuntu One activada en «configuración del sistema»?  
Si va a fluffychat -> Configuración -> Notificaciones -> Objetivos: ¿ve algún dispositivo «UbuntuPhone»?  
¿Ha probado a cerrar la sesión y volverla a abrir?  
¿Tiene instalada la última versión de FluffyChat disponible en OpenStore?  
¿Ha probado a activar y desactivar de nuevo el «modo avión»? A veces el servicio de notificaciones de UBports las envía con retraso (será arreglado pronto). Si aún tiene el problema, contácteme en la sala: [#fluffychat:matrix.org](fluffychat://#fluffychat:matrix.org)

#### ¿Por qué no puedo conectar con el puerto 8448?<a id="5-2"/>

¡Perdón! Confusamente la mayoría de los «homeservers» (servidores de datos) usan un certificado ssl diferente en el puerto 8448, que produce un error. Actualemente la solicitud «xmlhttp» en QML no permite esa clase de certificados.

#### ¿Por qué no puedo conectar con un certificado auto-firmado?<a id="5-3"/>

El mismo problema... Le recomiendo que use un certificado de Let's Encrypt.

## Acerca de FluffyChat<a id="6"/>

#### ¿Cómo se financia FluffyChat?<a id="6-1"/>

FluffyChat es financiado por la comunidad. Puede apoyar a FluffyChat en [Patreon](https://www.patreon.com/krillechritzelius) o [Liberapay](https://liberapay.com/KrilleChritzelius)
