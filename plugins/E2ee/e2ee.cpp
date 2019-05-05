#include <QDebug>
#include <olm/olm.h>
#include <QDataStream>
#include <QFile>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QMimeDatabase>
#include <QMimeType>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QUrl>
#include <QCommandLineParser>
#include <QStandardPaths>

#include "e2ee.h"

E2ee::E2ee() {
    m_olmAccount = nullptr;
    m_activeSession = nullptr;
}

E2ee::~E2ee() {
    if (m_olmAccount) {
        memset(m_olmAccount, 0, olm_account_size());
        free(m_olmAccount);
        m_olmAccount = nullptr;
    }
    if (m_activeSession) {
        memset(m_activeSession, 0, olm_session_size());
        free(m_activeSession);
        m_activeSession = nullptr;
    }
}


QString logError (QString errorMsg) {
    qDebug() << "🐞[E2EE] " + errorMsg;
    return errorMsg;
}

/** Creates a new Olm account and generates fingerprint and identity keys. These
are returned in a json object for Qml use.
**/
QString E2ee::createAccount(QString key) {

    size_t accountSize = olm_account_size(); // Get the memory size that is at least necessary for account init

    void * accountMemory = malloc( accountSize ); // Allocate the memory

    m_olmAccount = olm_account(accountMemory); // Initialise the olmAccount object

    size_t randomSize = olm_create_account_random_length(m_olmAccount); // Get the random size for account creation

    void * randomMemory = malloc( randomSize ); // Allocate the memory

    size_t resultOlmCreation = olm_create_account(m_olmAccount, randomMemory, randomSize); // Create the Olm account

    if (resultOlmCreation == olm_error()) {
        return logError(olm_account_last_error(m_olmAccount));
    }

    memset(randomMemory, 0, randomSize); // Set the allocated memory in ram to 0 everywhere

    free(randomMemory);  // Free the memory

    size_t olmAccountPickleMaxLength = olm_pickle_account_length(m_olmAccount);
    char olmAccountPickle[olmAccountPickleMaxLength+1];

    memset(olmAccountPickle, '0', olmAccountPickleMaxLength+1);
    if (olm_pickle_account(m_olmAccount, key.toLocal8Bit().data(), key.length(), olmAccountPickle, olmAccountPickleMaxLength) == olm_error()) {
        return logError(olm_account_last_error(m_olmAccount));
    }
    olmAccountPickle[olmAccountPickleMaxLength] = '\0';

    return QString::fromUtf8(olmAccountPickle);
}


/** Removes the Olm Account. Should be called on logout.
**/
bool E2ee::restoreAccount(QString olmAccountStr, QString key) {
    if (olm_unpickle_account(m_olmAccount, key.toLocal8Bit().data(), key.length(), olmAccountStr.toLocal8Bit().data(), olmAccountStr.length()) == olm_error()) {
        logError(olm_account_last_error(m_olmAccount));
        return false;
    }
    return true;
}


/** Returns the identity keys
**/
QString E2ee::getIdentityKeys() {
    size_t identityKeysLength = olm_account_identity_keys_length(m_olmAccount);
    char identityKeys[identityKeysLength+1];
    memset(identityKeys, '0', identityKeysLength+1);
    if (olm_account_identity_keys(m_olmAccount, identityKeys, identityKeysLength) == olm_error()) {
        return logError(olm_account_last_error(m_olmAccount));
    }

    identityKeys[identityKeysLength] = '\0';

    return QString::fromUtf8(identityKeys);
}


/** Removes the Olm Account. Should be called on logout.
**/
void E2ee::removeAccount() {
    olm_clear_account(m_olmAccount);
}


/** Signs a json string
**/
QString E2ee::signJsonString(QString jsonStr) {
    size_t signLength = olm_account_signature_length(m_olmAccount);
    char signedJsonStr[signLength+1];
    memset(signedJsonStr, '0', signLength+1);
    olm_account_sign(m_olmAccount, jsonStr.toLocal8Bit().data(), jsonStr.length(), signedJsonStr, signLength);
    signedJsonStr[signLength] = '\0';
    return QString::fromUtf8(signedJsonStr);
}


/** Returns the public parts of the unpublished one time keys for the account
**/
QString E2ee::getOneTimeKeys() {
    size_t keysLength = olm_account_one_time_keys_length(m_olmAccount);
    char oneTimeKeys[keysLength+1];
    memset(oneTimeKeys, '0', keysLength+1);
    if (olm_account_one_time_keys(m_olmAccount, oneTimeKeys, keysLength) == olm_error()) {
        return logError(olm_account_last_error(m_olmAccount));
    }
    oneTimeKeys[keysLength] = '\0';
    return QString::fromUtf8(oneTimeKeys);
}


void E2ee::markKeysAsPublished() {
    olm_account_mark_keys_as_published(m_olmAccount);
}


void E2ee::generateOneTimeKeys() {
    size_t maxNumber = olm_account_max_number_of_one_time_keys(m_olmAccount);
    size_t randomLength = olm_account_generate_one_time_keys_random_length(m_olmAccount, maxNumber);
    void * random = malloc( randomLength );
    if (olm_account_generate_one_time_keys(m_olmAccount, maxNumber, random, randomLength) == olm_error()) {
        logError(olm_account_last_error(m_olmAccount));
    }
}


QString E2ee::lastAccountError() {
    return QString::fromUtf8(olm_account_last_error(m_olmAccount));
}


QString E2ee::createOutboundSession(QString identityKey, QString oneTimeKey, QString key) {
    size_t randomLength = olm_create_outbound_session_random_length(m_activeSession);
    void * random = malloc( randomLength );
    if (olm_create_outbound_session(m_activeSession,
        m_olmAccount,
        identityKey.toLocal8Bit().data(),
        identityKey.length(),
        oneTimeKey.toLocal8Bit().data(),
        oneTimeKey.length(),
        random,
        randomLength
    ) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }
    return getSessionAndSessionID(key);
}


QString E2ee::createInboundSession(QString oneTimeKeyMessage, QString key){
    if (olm_create_inbound_session(m_activeSession,
        m_olmAccount,
        oneTimeKeyMessage.toLocal8Bit().data(),
        oneTimeKeyMessage.length()
    ) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }
    return getSessionAndSessionID(key);
}


QString E2ee::createInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage, QString key){
    if (olm_create_inbound_session_from(m_activeSession,
        m_olmAccount,
        identityKey.toLocal8Bit().data(),
        identityKey.length(),
        oneTimeKeyMessage.toLocal8Bit().data(),
        oneTimeKeyMessage.length()
    ) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }
    return getSessionAndSessionID(key);
}


QString E2ee::getSessionAndSessionID(QString key) {
    size_t idLength = olm_session_id_length(m_activeSession);
    char id[idLength+1];
    memset(id, '0', idLength+1);
    if (olm_session_id(m_activeSession, id, idLength) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }
    id[idLength] = '\0';

    size_t sessionPickleMaxLength = olm_pickle_session_length(m_activeSession);
    char sessionPickle[sessionPickleMaxLength+1];

    memset(sessionPickle, '0', sessionPickleMaxLength+1);
    if (olm_pickle_session(m_activeSession, key.toLocal8Bit().data(), key.length(), sessionPickle, sessionPickleMaxLength) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }
    sessionPickle[sessionPickleMaxLength] = '\0';

    return "{\"id\":" + QString::fromUtf8(id) + ",\"session\":" + QString::fromUtf8(sessionPickle) + "}";
}


void E2ee::setActiveSession(QString olmSessionStr, QString key){
    if (olm_unpickle_session(m_activeSession, key.toLocal8Bit().data(), key.length(), olmSessionStr.toLocal8Bit().data(), olmSessionStr.length()) == olm_error()) {
        logError(olm_session_last_error(m_activeSession));
    }
}


bool E2ee::matchesInboundSession(QString oneTimeKeyMessage){
    size_t result = olm_matches_inbound_session(m_activeSession, oneTimeKeyMessage.toLocal8Bit().data(), oneTimeKeyMessage.length());
    if (result == olm_error()) {
        logError(olm_session_last_error(m_activeSession));
        return false;
    }
    else if (result == 1) {
        return true;
    }
    return false;
}


bool E2ee::matchesInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage){
    size_t result = olm_matches_inbound_session_from(m_activeSession, identityKey.toLocal8Bit().data(), identityKey.length(), oneTimeKeyMessage.toLocal8Bit().data(), oneTimeKeyMessage.length());
    if (result == olm_error()) {
        logError(olm_session_last_error(m_activeSession));
        return false;
    }
    else if (result == 1) {
        return true;
    }
    return false;
}


void E2ee::removeOneTimeKeys(){
    olm_remove_one_time_keys(m_olmAccount, m_activeSession);
}


QString E2ee::encryptMessageType(){
    size_t result = olm_encrypt_message_type(m_activeSession);
    if (result == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }
    else if (result == OLM_MESSAGE_TYPE_PRE_KEY) {
        return "OLM_MESSAGE_TYPE_PRE_KEY";
    }
    else if (result == OLM_MESSAGE_TYPE_MESSAGE) {
        return "OLM_MESSAGE_TYPE_MESSAGE";
    }
    return logError("UNKNOWN_RESULT");
}


QString E2ee::encrypt(QString plaintext){
    size_t randomLength = olm_encrypt_random_length(m_activeSession);
    void * random = malloc( randomLength );

    size_t messageLength = olm_encrypt_message_length(m_activeSession, plaintext.length());
    char message[messageLength+1];

    memset(message, '0', messageLength+1);

    if (olm_encrypt(m_activeSession,
        plaintext.toLocal8Bit().data(),
        plaintext.length(),
        random,
        randomLength,
        message,
        messageLength
    ) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }

    message[messageLength] = '\0';

    return QString::fromUtf8(message);
}


QString E2ee::decrypt(QString message){
    size_t messageType = olm_encrypt_message_type(m_activeSession);

    size_t plaintextLength = olm_decrypt_max_plaintext_length(m_activeSession,
        messageType,
        message.toLocal8Bit().data(),
        message.length()
    );
    char plaintext[plaintextLength+1];

    memset(plaintext, '0', plaintextLength+1);

    if (olm_decrypt(m_activeSession,
        messageType,
        message.toLocal8Bit().data(),
        message.length(),
        plaintext,
        plaintextLength
    ) == olm_error()) {
        return logError(olm_session_last_error(m_activeSession));
    }

    plaintext[plaintextLength] = '\0';

    return QString::fromUtf8(plaintext);
}


QString E2ee::sha256(QString input){
    size_t utilitySize = olm_utility_size();
    void * utilityMemory = malloc( utilitySize );
    OlmUtility * utility = olm_utility(utilityMemory);

    size_t outputLength = olm_sha256_length(utility);
    char output[outputLength+1];
    memset(output, '0', outputLength+1);

    olm_sha256(utility,
        input.toLocal8Bit().data(),
        input.length(),
        output,
        outputLength
    );

    olm_clear_utility(utility);
    return QString::fromUtf8(output);
}


bool E2ee::ed25519Verify(QString key, QString message, QString signature){
    size_t utilitySize = olm_utility_size();
    void * utilityMemory = malloc( utilitySize );
    OlmUtility * utility = olm_utility(utilityMemory);

    size_t result = olm_ed25519_verify(utility,
        key.toLocal8Bit().data(),
        key.length(),
        message.toLocal8Bit().data(),
        message.length(),
        signature.toLocal8Bit().data(),
        signature.length()
    );

    olm_clear_utility(utility);

    if (result == 1) {
        return true;
    }
    return false;
}


/** Uploads an encrypted or unencrypted file.
**/
bool E2ee::uploadFile(QString path, QString uploadUrl, QString token) {

    QFile file(path);

    if(!(file.exists() && file.open(QIODevice::ReadOnly))) {
        return false;
    }

    QString fileName = path.split("/").last();

    QByteArray data = file.readAll();
    file.close();

    uploadUrl = uploadUrl + "?filename=" + fileName;
    token = "Bearer " + token;

    QUrl url(uploadUrl);
    QNetworkRequest request(url);
    QString mimeType = QMimeDatabase().mimeTypeForFile( path ).name();
    request.setRawHeader(QByteArray("Authorization"), token.toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, mimeType);

    QNetworkAccessManager manager;
    QNetworkReply* reply = manager.post(request, data);
    QEventLoop loop;
    connect(reply, SIGNAL(uploadProgress(qint64, qint64)),
    this, SLOT(uploadProgressSlot(qint64, qint64)));
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    QByteArray response = reply->readAll();
    QString dataReply(response);
    uploadFinished(dataReply, mimeType, fileName, data.size());

    return true;
}


void E2ee::uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal) {
    uploadProgress(bytesSent, bytesTotal);
}
