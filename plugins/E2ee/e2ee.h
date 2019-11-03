#ifndef E2EE_H
#define E2EE_H

#include <QObject>
#include <QJsonObject>
#include <olm/olm.h>

class E2ee: public QObject {
    Q_OBJECT

private:
    OlmAccount* m_olmAccount;
    OlmSession* m_activeSession;

    bool m_isSessionActive;
    bool m_isAccountInitialized;

    QJsonObject getSessionAndSessionID(QString key);

    bool isAccountInitialized();
    bool isSessionActive();

    OlmOutboundGroupSession * m_activeOutboundGroupSession;
    OlmInboundGroupSession *  m_activeInboundGroupSession;
         
    QJsonObject stringToJsonObject(const QByteArray &jsonString) const;

public:
    E2ee();
    ~E2ee();

    // TODO: More detailed comments for doxygen

    /** Uploads an encrypted or unencrypted file. Returns false if the given file
     * does not exist or can not be opened.
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
    Q_INVOKABLE QJsonObject createOutboundSession(QString identityKey, QString oneTimeKey, QString key);

    /** Create a new in-bound session for sending/receiving messages from an
     * incoming PRE_KEY message. **/
    Q_INVOKABLE QJsonObject createInboundSession(QString oneTimeKeyMessage, QString key);

    /** Create a new in-bound session for sending/receiving messages from an
     * incoming PRE_KEY message. **/
    Q_INVOKABLE QJsonObject createInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage, QString key);

    /** Sets the active session by the given string **/
    Q_INVOKABLE void setActiveSession(QString olmSessionStr, QString key);

    // Note: Functions below needs an active session!

    /** Removes the active session **/
    Q_INVOKABLE void removeSession();

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
    Q_INVOKABLE QJsonObject encrypt(QString plaintext);

    /** Decrypts a message using the session. Returns the plaintext. **/
    Q_INVOKABLE QJsonObject decrypt(QString message);

    /** Calculates the SHA-256 hash of the input and encodes it as base64. **/
    Q_INVOKABLE QJsonObject sha256(QString input);

    /** Calculates the SHA-256 hash of the input and encodes it as base64.  **/
    Q_INVOKABLE bool ed25519Verify(QString key, QString message, QString signature);

    /** Creates a new out-bound megolm session for sending events/messages in a room.
     *  Returns the base64 encoded pickle for the OlmGroupSession. **/
    Q_INVOKABLE QString createOutboundGroupSession(QString key);

    /** Returns the outbound olm group session key. */
    Q_INVOKABLE QString getOutboundGroupSessionKey() const;

    /** Returns outbound olm group session session id. */
    Q_INVOKABLE QString getOutboundGroupSessionId() const;

    /** Restores session from base64 session pickle string. */
    Q_INVOKABLE bool restoreOutboundGroupSession(QString pickle, QString key);

    /** Encrypts group message. */
    Q_INVOKABLE QJsonObject encryptGroupMessage(QString plaintext) const;

    /** Creates a new in-bound megolm session (for receiving events/messages from a room)
     *  from Megolm session key.
     *  Returns the base64 encoded pickle for the OlmGroupSession. **/
    Q_INVOKABLE QString createInboundGroupSession(QString sessionKey, QString pickleKey);

    /** Restores session from base64 session pickle string. */
    Q_INVOKABLE bool restoreInboundGroupSession(QString pickle, QString key);

    /** Decrypts group message. */
    Q_INVOKABLE QJsonObject decryptGroupMessage(QString cipherText) const;

public slots:
    void uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal);

signals:
    void uploadFinished(QString reply, QString mimeType, QString fileName, int size);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

};

#endif
