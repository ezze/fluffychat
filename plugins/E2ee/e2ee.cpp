#include <QDebug>
#include <QDataStream>
#include <QFile>
#include <QMimeDatabase>
#include <QMimeType>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QUrl>
#include <QCommandLineParser>
#include <QByteArray>
#include <QJsonObject>
#include <QJsonDocument>

#include "e2eeSeed.h"
#include "e2ee.h"

E2ee::E2ee() : m_isSessionActive(false), m_isAccountInitialized(false)
{

    size_t accountSize = olm_account_size();   // Get the memory size that is at least necessary for account init
    void *accountMemory = malloc(accountSize); // Allocate the memory
    m_olmAccount = olm_account(accountMemory); // Initialise the olmAccount object

    size_t sessionSize = olm_session_size();            // Get the memory size that is at least necessary for account init
    m_activeSession = olm_session(malloc(sessionSize)); // Allocate the memory

    size_t outboundGroupSessionSize = olm_outbound_group_session_size();
    void *outboundGroupSessionMemory = malloc(outboundGroupSessionSize);
    m_activeOutboundGroupSession = olm_outbound_group_session(outboundGroupSessionMemory);

    size_t inboundGroupSessionSize = olm_inbound_group_session_size();
    void *inboundGroupSessionMemory = malloc(inboundGroupSessionSize);
    m_activeInboundGroupSession = olm_inbound_group_session(inboundGroupSessionMemory);
}

E2ee::~E2ee()
{
    if (m_olmAccount)
    {
        memset(m_olmAccount, '0', olm_account_size());
        free(m_olmAccount);
        m_olmAccount = nullptr;
    }
    if (m_activeSession)
    {
        memset(m_activeSession, '0', olm_session_size());
        free(m_activeSession);
        m_activeSession = nullptr;
    }
}

QString logError(QString errorMsg)
{
    QString logMsg = "🐞[E2EE] " + errorMsg;
    qDebug() << logMsg;
    return "";
}

bool E2ee::isAccountInitialized()
{
    return m_isAccountInitialized;
}

bool E2ee::isSessionActive()
{
    return isAccountInitialized() && m_isSessionActive;
}

bool E2ee::uploadFile(QString path, QString uploadUrl, QString token)
{

    QFile file(path);

    if (!(file.exists() && file.open(QIODevice::ReadOnly)))
    {
        logError("File does not exist or can not be opened");
        return false;
    }

    QString fileName = path.split("/").last();

    QByteArray data = file.readAll(); // TODO: Encrypt file
    file.close();

    uploadUrl = uploadUrl + "?filename=" + fileName;
    token = "Bearer " + token;

    QUrl url(uploadUrl);
    QNetworkRequest request(url);
    QString mimeType = QMimeDatabase().mimeTypeForFile(path).name();
    request.setRawHeader(QByteArray("Authorization"), token.toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, mimeType);

    QNetworkAccessManager manager;
    QNetworkReply *reply = manager.post(request, data);
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

QString E2ee::createAccount(QString key)
{

    size_t randomSize = olm_create_account_random_length(m_olmAccount); // Get the random size for account creation
    m_isAccountInitialized = false;
    E2eeSeed seed(randomSize);

    size_t resultOlmCreation = olm_create_account(m_olmAccount, seed.random(), randomSize); // Create the Olm account

    if (resultOlmCreation == olm_error())
    {
        return logError(olm_account_last_error(m_olmAccount));
    }

    size_t olmAccountPickleMaxLength = olm_pickle_account_length(m_olmAccount);
    char olmAccountPickle[olmAccountPickleMaxLength + 1];

    memset(olmAccountPickle, '0', olmAccountPickleMaxLength + 1); // TODO: Do we need this?
    size_t length = olm_pickle_account(m_olmAccount, key.toLocal8Bit().data(), key.length(), olmAccountPickle, olmAccountPickleMaxLength);
    if (length == olm_error())
    {
        return logError(olm_account_last_error(m_olmAccount));
    }
    olmAccountPickle[length] = '\0';

    m_isAccountInitialized = true;

    return QString::fromUtf8(olmAccountPickle);
}

bool E2ee::restoreAccount(QString olmAccountStr, QString key)
{
    m_isAccountInitialized = false;
    if (olm_unpickle_account(m_olmAccount, key.toLocal8Bit().data(), key.length(), olmAccountStr.toLocal8Bit().data(), olmAccountStr.length()) == olm_error())
    {
        logError(olm_account_last_error(m_olmAccount));
        return false;
    }
    m_isAccountInitialized = true;
    return true;
}

QString E2ee::getIdentityKeys()
{
    if (!isAccountInitialized())
        return logError("No m_olmAccount initialized!");

    size_t identityKeysLength = olm_account_identity_keys_length(m_olmAccount);
    char identityKeys[identityKeysLength + 1];
    memset(identityKeys, '0', identityKeysLength + 1);
    if (olm_account_identity_keys(m_olmAccount, identityKeys, identityKeysLength) == olm_error())
    {
        return logError(olm_account_last_error(m_olmAccount));
    }

    identityKeys[identityKeysLength] = '\0';

    m_isAccountInitialized = true;

    return QString::fromUtf8(identityKeys);
}

void E2ee::removeAccount()
{
    if (!isAccountInitialized())
        return;

    removeSession();

    olm_clear_account(m_olmAccount);
    m_isAccountInitialized = false;
}

QString E2ee::signJsonString(QString jsonStr)
{
    if (!isAccountInitialized())
        return logError("No m_olmAccount initialized!");

    size_t signLength = olm_account_signature_length(m_olmAccount);
    char signedJsonStr[signLength + 1];
    memset(signedJsonStr, '0', signLength + 1);
    olm_account_sign(m_olmAccount, jsonStr.toLocal8Bit().data(), jsonStr.length(), signedJsonStr, signLength);
    signedJsonStr[signLength] = '\0';
    return QString::fromUtf8(signedJsonStr);
}

QString E2ee::getOneTimeKeys()
{
    if (!isAccountInitialized())
        return logError("No m_olmAccount initialized!");

    size_t keysLength = olm_account_one_time_keys_length(m_olmAccount);
    char oneTimeKeys[keysLength + 1];
    memset(oneTimeKeys, '0', keysLength + 1);
    if (olm_account_one_time_keys(m_olmAccount, oneTimeKeys, keysLength) == olm_error())
    {
        return logError(olm_account_last_error(m_olmAccount));
    }
    oneTimeKeys[keysLength] = '\0';
    return QString::fromUtf8(oneTimeKeys);
}

void E2ee::markKeysAsPublished()
{
    if (!isAccountInitialized())
        return;

    olm_account_mark_keys_as_published(m_olmAccount);
}

void E2ee::generateOneTimeKeys()
{
    if (!isAccountInitialized())
        return;

    size_t maxNumber = olm_account_max_number_of_one_time_keys(m_olmAccount);
    size_t randomLength = olm_account_generate_one_time_keys_random_length(m_olmAccount, maxNumber);
    E2eeSeed seed(randomLength);

    if (olm_account_generate_one_time_keys(m_olmAccount, maxNumber, seed.random(), randomLength) == olm_error())
    {
        logError(olm_account_last_error(m_olmAccount));
    }
}

QString E2ee::lastAccountError()
{
    if (!isAccountInitialized())
        return logError("No m_olmAccount initialized!");

    return QString::fromUtf8(olm_account_last_error(m_olmAccount));
}

QJsonObject E2ee::createOutboundSession(QString identityKey, QString oneTimeKey, QString key)
{
    if (!isAccountInitialized())
    {
        logError("No m_olmAccount initialized!");
        return QJsonObject{};
    }

    size_t randomLength = olm_create_outbound_session_random_length(m_activeSession);

    E2eeSeed seed(randomLength);

    m_isSessionActive = false;

    if (olm_create_outbound_session(m_activeSession,
                                    m_olmAccount,
                                    identityKey.toLocal8Bit().data(),
                                    identityKey.length(),
                                    oneTimeKey.toLocal8Bit().data(),
                                    oneTimeKey.length(),
                                    seed.random(),
                                    randomLength) == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return QJsonObject{};
    }

    m_isSessionActive = true;

    return getSessionAndSessionID(key);
}

QJsonObject E2ee::createInboundSession(QString oneTimeKeyMessage, QString key)
{
    if (!isAccountInitialized())
    {
        logError("No m_olmAccount initialized!");
        return QJsonObject{};
    }

    m_isSessionActive = false;

    if (olm_create_inbound_session(m_activeSession,
                                   m_olmAccount,
                                   oneTimeKeyMessage.toLocal8Bit().data(),
                                   oneTimeKeyMessage.length()) == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return QJsonObject{};
    }
    else
    {
        olm_remove_one_time_keys(m_olmAccount, m_activeSession);
    }

    m_isSessionActive = true;

    return getSessionAndSessionID(key);
}

QJsonObject E2ee::createInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage, QString key)
{

    m_isSessionActive = false;

    if (!isAccountInitialized())
    {
        logError("No m_olmAccount initialized!");
        return QJsonObject{};
    }

    if (olm_create_inbound_session_from(m_activeSession,
                                        m_olmAccount,
                                        identityKey.toLocal8Bit().data(),
                                        identityKey.length(),
                                        oneTimeKeyMessage.toLocal8Bit().data(),
                                        oneTimeKeyMessage.length()) == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return QJsonObject{};
    }
    else
    {
        olm_remove_one_time_keys(m_olmAccount, m_activeSession);
    }

    m_isSessionActive = true;

    return getSessionAndSessionID(key);
}

void E2ee::setActiveSession(QString olmSessionStr, QString key)
{
    if (!isAccountInitialized())
    {
        logError("No Account initialized!");
        return;
    }

    if (olm_unpickle_session(m_activeSession, key.toLocal8Bit().data(), key.length(), olmSessionStr.toLocal8Bit().data(), olmSessionStr.length()) == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
    }
    else
    {
        m_isSessionActive = true;
    }
}

void E2ee::removeSession()
{
    if (!isSessionActive())
        return;
    olm_clear_session(m_activeSession);
    m_isSessionActive = false;
}

QJsonObject E2ee::getSessionAndSessionID(QString key)
{
    if (!isSessionActive())
    {
        logError("No m_activeSession initialized!");
        return QJsonObject{};
    }

    size_t idLength = olm_session_id_length(m_activeSession);
    char id[idLength + 1];
    memset(id, '0', idLength + 1);
    if (olm_session_id(m_activeSession, id, idLength) == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return QJsonObject{};
    }
    id[idLength] = '\0';

    size_t sessionPickleMaxLength = olm_pickle_session_length(m_activeSession);
    char sessionPickle[sessionPickleMaxLength + 1];
    memset(sessionPickle, '0', sessionPickleMaxLength + 1);
    size_t length = olm_pickle_session(m_activeSession, key.toLocal8Bit().data(), key.length(), sessionPickle, sessionPickleMaxLength);

    if (length == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return QJsonObject{};
    }
    sessionPickle[length] = '\0';

    return QJsonObject{
        {"id", QString::fromUtf8(id)},
        {"session", QString::fromUtf8(sessionPickle)}};
}

bool E2ee::matchesInboundSession(QString oneTimeKeyMessage)
{
    if (!isSessionActive())
        return false;

    size_t result = olm_matches_inbound_session(m_activeSession, oneTimeKeyMessage.toLocal8Bit().data(), oneTimeKeyMessage.length());
    if (result == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return false;
    }
    else if (olm_session_last_error(m_activeSession) == "BAD_MESSAGE_FORMAT")
    {
        return false;
    }
    else if (result == 1)
    {
        return true;
    }
    return false;
}

bool E2ee::matchesInboundSessionFrom(QString identityKey, QString oneTimeKeyMessage)
{
    if (!isSessionActive())
        return false;

    size_t result = olm_matches_inbound_session_from(m_activeSession, identityKey.toLocal8Bit().data(), identityKey.length(), oneTimeKeyMessage.toLocal8Bit().data(), oneTimeKeyMessage.length());
    if (result == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return false;
    }
    else if (result == 1)
    {
        return true;
    }
    return false;
}

void E2ee::removeOneTimeKeys()
{
    if (!isSessionActive())
        return;

    olm_remove_one_time_keys(m_olmAccount, m_activeSession);
}

QString E2ee::encryptMessageType()
{
    if (!isSessionActive())
        return logError("No m_activeSession initialized!");

    size_t result = olm_encrypt_message_type(m_activeSession);
    if (result == olm_error())
    {
        return logError(olm_session_last_error(m_activeSession));
    }
    else if (result == OLM_MESSAGE_TYPE_PRE_KEY)
    {
        return "OLM_MESSAGE_TYPE_PRE_KEY";
    }
    else if (result == OLM_MESSAGE_TYPE_MESSAGE)
    {
        return "OLM_MESSAGE_TYPE_MESSAGE";
    }
    return logError("UNKNOWN_RESULT");
}

QString E2ee::encrypt(QString plaintext)
{
    if (!isSessionActive())
    {
        return logError("No m_activeSession initialized!");
    }

    size_t randomLength = olm_encrypt_random_length(m_activeSession);
    E2eeSeed seed(randomLength);

    size_t messageLength = olm_encrypt_message_length(m_activeSession, plaintext.length());
    char message[messageLength + 1];

    memset(message, '0', messageLength + 1);

    if (olm_encrypt(m_activeSession,
                    plaintext.toLocal8Bit().data(),
                    plaintext.length(),
                    seed.random(),
                    randomLength,
                    message,
                    messageLength) == olm_error())
    {
        return logError(olm_session_last_error(m_activeSession));
    }

    message[messageLength] = '\0';

    return QString(message);
}

QJsonObject E2ee::decrypt(QString message)
{
    if (!isSessionActive())
    {
        logError("No m_activeSession initialized!");
        return QJsonObject{};
    }

    size_t messageType = olm_encrypt_message_type(m_activeSession);

    size_t plaintextMaxLength = olm_decrypt_max_plaintext_length(m_activeSession,
                                                                 messageType,
                                                                 message.toLocal8Bit().data(),
                                                                 message.length());
    char plaintext[plaintextMaxLength + 1];

    memset(plaintext, '0', plaintextMaxLength + 1);

    size_t plaintextLength = olm_decrypt(m_activeSession,
                                         messageType,
                                         message.toLocal8Bit().data(),
                                         message.length(),
                                         plaintext,
                                         plaintextMaxLength);

    if (plaintextLength == olm_error())
    {
        logError(olm_session_last_error(m_activeSession));
        return QJsonObject{};
    }

    return stringToJsonObject(QByteArray(plaintext, plaintextLength));
}

QJsonObject E2ee::sha256(QString input)
{
    size_t utilitySize = olm_utility_size();
    void *utilityMemory = malloc(utilitySize);
    OlmUtility *utility = olm_utility(utilityMemory);

    size_t outputLength = olm_sha256_length(utility);
    char output[outputLength + 1];
    memset(output, '0', outputLength + 1);

    olm_sha256(utility,
               input.toLocal8Bit().data(),
               input.length(),
               output,
               outputLength);

    olm_clear_utility(utility);
    free(utilityMemory);
    utility = nullptr;

    return stringToJsonObject(QByteArray(output, outputLength));
}

QJsonObject E2ee::stringToJsonObject(const QByteArray &jsonString) const
{
    QJsonDocument doc = QJsonDocument::fromJson(jsonString);
    if (doc.isNull())
    {
        logError("Failed to create QJsonDocument from json string:");
        logError(jsonString);
        return QJsonObject{};
    }
    if (doc.isObject())
    {
        return doc.object();
    }
    else
    {
        logError("failed to create object from json document:");
        logError(doc.toJson());
        return QJsonObject{};
    }
}

bool E2ee::ed25519Verify(QString key, QString message, QString signature)
{
    size_t utilitySize = olm_utility_size();
    void *utilityMemory = malloc(utilitySize);
    OlmUtility *utility = olm_utility(utilityMemory);

    size_t result = olm_ed25519_verify(utility,
                                       key.toLocal8Bit().data(),
                                       key.length(),
                                       message.toLocal8Bit().data(),
                                       message.length(),
                                       signature.toLocal8Bit().data(),
                                       signature.length());

    const char *lastError = olm_utility_last_error(utility);

    olm_clear_utility(utility);
    free(utilityMemory);
    utility = nullptr;

    if (lastError != "BAD_MESSAGE_MAC" || lastError != "INVALID BASE64")
    {
        return true;
    }
    return false;
}

void E2ee::uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal)
{
    uploadProgress(bytesSent, bytesTotal);
}

QString E2ee::createOutboundGroupSession(QString key)
{
    size_t randomLength = olm_init_outbound_group_session_random_length(this->m_activeOutboundGroupSession);
    E2eeSeed megolmKeySeed(randomLength);

    olm_clear_outbound_group_session(this->m_activeOutboundGroupSession);

    size_t error = olm_init_outbound_group_session(this->m_activeOutboundGroupSession,
                                                   megolmKeySeed.random(),
                                                   megolmKeySeed.length());
    if (error == olm_error())
    {
        logError(QString("olm_init_outbound_group_session failed with: ") + QString(olm_outbound_group_session_last_error(this->m_activeOutboundGroupSession)));
        return "";
    }

    size_t pickleLength = olm_pickle_outbound_group_session_length(this->m_activeOutboundGroupSession);

    char pickle[pickleLength + 1];
    memset(pickle, '0', pickleLength + 1);

    size_t length = olm_pickle_outbound_group_session(this->m_activeOutboundGroupSession,
                                                      key.toLocal8Bit().data(), key.length(),
                                                      pickle, pickleLength);

    if (length == olm_error())
    {
        logError(QString("olm_pickle_outbound_group_session failed with: ") + QString(olm_outbound_group_session_last_error(this->m_activeOutboundGroupSession)));
        return "";
    }

    pickle[length] = '\0';
    return QString(pickle);
}

QString E2ee::getOutboundGroupSessionKey() const
{
    size_t keyLength = olm_outbound_group_session_key_length(this->m_activeOutboundGroupSession);
    char key[keyLength + 1];
    memset(key, '0', keyLength + 1);
    size_t length = olm_outbound_group_session_key(this->m_activeOutboundGroupSession,
                                                   reinterpret_cast<uint8_t *>(key),
                                                   keyLength);

    if (length == olm_error())
    {
        logError(QString("olm_outbound_group_session_key failed with: ") + QString(olm_outbound_group_session_last_error(this->m_activeOutboundGroupSession)));
        return "";
    }

    key[length] = '\0';
    return QString(key);
}

QString E2ee::getOutboundGroupSessionId() const
{
    size_t idLength = olm_outbound_group_session_id_length(this->m_activeOutboundGroupSession);
    char id[idLength + 1];
    memset(id, '0', idLength + 1);

    size_t length = olm_outbound_group_session_id(this->m_activeOutboundGroupSession,
                                                  reinterpret_cast<uint8_t *>(id),
                                                  idLength);

    if (length == olm_error())
    {
        logError(QString("olm_outbound_group_session_id failed with: ") + QString(olm_outbound_group_session_last_error(this->m_activeOutboundGroupSession)));
        return "";
    }

    id[length] = '\0';
    return QString(id);
}

bool E2ee::restoreOutboundGroupSession(QString pickle, QString key)
{
    olm_clear_outbound_group_session(this->m_activeOutboundGroupSession);
    size_t error = olm_unpickle_outbound_group_session(this->m_activeOutboundGroupSession,
                                                       key.toLocal8Bit().data(), key.length(),
                                                       pickle.toLocal8Bit().data(), pickle.length());
    if (error == olm_error())
    {
        logError(QString("olm_unpickle_outbound_group_session failed with: ") + QString(olm_outbound_group_session_last_error(this->m_activeOutboundGroupSession)));
        return false;
    }

    return true;
}

QString E2ee::encryptGroupMessage(QString plaintext) const
{
    size_t cipherLength = olm_group_encrypt_message_length(this->m_activeOutboundGroupSession,
                                                           plaintext.length());
    char cipherText[cipherLength + 1];
    memset(cipherText, '0', cipherLength + 1);

    size_t length = olm_group_encrypt(this->m_activeOutboundGroupSession,
                                      reinterpret_cast<uint8_t *>(plaintext.toLocal8Bit().data()),
                                      plaintext.length(),
                                      reinterpret_cast<uint8_t *>(cipherText),
                                      cipherLength);

    if (length == olm_error())
    {
        return logError("olm_group_encrypt dailed with: " + QString(olm_outbound_group_session_last_error(this->m_activeOutboundGroupSession)));
    }

    cipherText[length] = '\0';
    return QString(cipherText);
}

QString E2ee::createInboundGroupSession(QString sessionKey, QString pickleKey)
{
    olm_clear_inbound_group_session(this->m_activeInboundGroupSession);

    size_t error = olm_init_inbound_group_session(this->m_activeInboundGroupSession,
                                                  reinterpret_cast<uint8_t *>(sessionKey.toLocal8Bit().data()),
                                                  sessionKey.length());

    if (error == olm_error())
    {
        logError(QString("olm_init_inbound_group_session failed with:") + QString(olm_inbound_group_session_last_error(this->m_activeInboundGroupSession)));
        return "";
    }

    size_t pickleLength = olm_pickle_inbound_group_session_length(this->m_activeInboundGroupSession);

    char pickle[pickleLength + 1];
    memset(pickle, '0', pickleLength + 1);

    size_t length = olm_pickle_inbound_group_session(this->m_activeInboundGroupSession,
                                                     pickleKey.toLocal8Bit().data(),
                                                     pickleKey.length(),
                                                     pickle,
                                                     pickleLength);

    if (length == olm_error())
    {
        logError(QString("olm_pickle_inbound_group_session failed with: ") + QString(olm_inbound_group_session_last_error(this->m_activeInboundGroupSession)));
        return "";
    }

    pickle[length] = '\0';
    return QString(pickle);
}

bool E2ee::restoreInboundGroupSession(QString pickle, QString key)
{
    olm_clear_inbound_group_session(this->m_activeInboundGroupSession);
    size_t error = olm_unpickle_inbound_group_session(this->m_activeInboundGroupSession,
                                                      key.toLocal8Bit().data(), key.length(),
                                                      pickle.toLocal8Bit().data(), pickle.length());
    if (error == olm_error())
    {
        logError(QString("olm_unpickle_inbound_group_session failed with: ") + QString(olm_inbound_group_session_last_error(this->m_activeInboundGroupSession)));
        return false;
    }

    return true;
}

QJsonObject E2ee::decryptGroupMessage(QString cipherText) const
{
    size_t plaintextMaxLength = olm_group_decrypt_max_plaintext_length(
        this->m_activeInboundGroupSession,
        reinterpret_cast<uint8_t *>(cipherText.toLocal8Bit().data()),
        cipherText.length());

    uint32_t messageIndex;
    char plaintext[plaintextMaxLength + 1];
    memset(plaintext, '0', plaintextMaxLength + 1);

    size_t length = olm_group_decrypt(this->m_activeInboundGroupSession,
                                      reinterpret_cast<uint8_t *>(cipherText.toLocal8Bit().data()),
                                      cipherText.length(),
                                      reinterpret_cast<uint8_t *>(plaintext),
                                      plaintextMaxLength,
                                      &messageIndex);

    if (length == olm_error())
    {
        logError(QString("olm_group_decrypt failed with: ") + QString(olm_inbound_group_session_last_error(this->m_activeInboundGroupSession)));
        return QJsonObject{};
    }

    plaintext[length] = '\0';
    return stringToJsonObject(plaintext);
}
