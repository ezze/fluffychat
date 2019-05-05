#ifndef E2EE_H
#define E2EE_H

#include <QObject>
#include <olm/olm.h>
#include <QJsonObject>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QUrl>
#include <QCommandLineParser>

class E2ee: public QObject {
    Q_OBJECT

private:
    OlmAccount* m_olmAccount;
    OlmSession* m_activeSession;

public:
    E2ee();
    ~E2ee();

    /** Uploads an encrypted or unencrypted file.
    **/
    Q_INVOKABLE bool uploadFile(QString path, QString url, QString token);

    /** Creates a new account and returns the base64 encoded account data **/
    Q_INVOKABLE QString createAccount(QString key);

    /** Restores an account with a given base64 encoded string **/
    Q_INVOKABLE bool restoreAccount(QString olmAccountStr, QString key);

    // Note: All functions below need a call of createAccount or restoreAccount first!

    /** Removes the active account **/
    Q_INVOKABLE void removeAccount();

    /** Returns the identity keys in a json object **/
    Q_INVOKABLE QString getIdentityKeys();

    /** Signs a given string with the identity key **/
    Q_INVOKABLE QString signJsonString(QString jsonStr);

    /** Returns the public parts of the unpublished one time keys for the account **/
    Q_INVOKABLE QString getOneTimeKeys();

    /** Marks all onetimekeys as published **/
    Q_INVOKABLE void markKeysAsPublished();

    /** Generate more one time keys and removes all old unpublished keys **/
    Q_INVOKABLE void generateOneTimeKeys();

    /** A null terminated string describing the most recent error to happen to an
     * account */
    Q_INVOKABLE QString lastAccountError();

    /** Creates a new out-bound session for sending messages to a given identity_key
     * and one_time_key. Returns a json object with the session ID and the base64
     * encoded OlmSession. **/
    Q_INVOKABLE QString createOutboundSession(QString identityKey, QString oneTimeKey, QString key);

    /** Create a new in-bound session for sending/receiving messages from an
     * incoming PRE_KEY message. **/
    Q_INVOKABLE QString createInboundSession(QString oneTimeKeyMessage, QString key);

    /** Create a new in-bound session for sending/receiving messages from an
     * incoming PRE_KEY message. **/
    Q_INVOKABLE QString createInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage, QString key);

    /** Sets the active session by the given string **/
    Q_INVOKABLE void setActiveSession(QString olmSessionStr);

    // Note: Functions below needs an active session!

    /** Checks if the PRE_KEY message is for this in-bound session. This can happen
     * if multiple messages are sent to this account before this account sends a
     * message in reply. **/
    Q_INVOKABLE bool matchesInboundSession(QString oneTimeKeyMessage);

    /** Checks if the PRE_KEY message is for this in-bound session. This can happen
     * if multiple messages are sent to this account before this account sends a
     * message in reply. **/
    Q_INVOKABLE bool matchesInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage);

    /** Removes the one time keys that the session used from the account. **/
    Q_INVOKABLE void removeOneTimeKeys();

    /** The type of the next message that olm_encrypt() will return. Returns
     * OLM_MESSAGE_TYPE_PRE_KEY if the message will be a PRE_KEY message.
     * Returns OLM_MESSAGE_TYPE_MESSAGE if the message will be a normal message. **/
    Q_INVOKABLE QString encryptMessageType();

    /** Encrypts a message using the session. Returns the encrypted base64
     * string. **/
    Q_INVOKABLE QString encrypt(QString plaintext);

    /** Decrypts a message using the session. Returns the plaintext. **/
    Q_INVOKABLE QString decrypt(QString message);

    /** Calculates the SHA-256 hash of the input and encodes it as base64. **/
    Q_INVOKABLE QString sha256(QString input);

    /** Calculates the SHA-256 hash of the input and encodes it as base64.  **/
    Q_INVOKABLE bool ed25519Verify(QString key, QString message, QString signature);


public slots:
    void uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal);

signals:
    void uploadFinished(QString reply, QString mimeType, QString fileName, int size);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

};

#endif
