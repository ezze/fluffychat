#include <QDebug>
#include <olm/olm.h>
#include <QFile>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QUrl>
#include <QCommandLineParser>

#include "e2ee.h"

E2ee::E2ee() {
    m_olmAccount = nullptr;
}

E2ee::~E2ee() {
    if (m_olmAccount) {
        memset(m_olmAccount, 0, olm_account_size());
        free(m_olmAccount);
        m_olmAccount = nullptr;
    }
}

/** Creates a new Olm account and generates fingerprint and identity keys. These
are returned in a json object for Qml use.
**/
QString E2ee::createAccount() {

    size_t accountSize = olm_account_size(); // Get the memory size that is at least necessary for account init

    void * accountMemory = malloc( accountSize ); // Allocate the memory

    m_olmAccount = olm_account(accountMemory); // Initialise the olmAccount object

    size_t randomSize = olm_create_account_random_length(m_olmAccount); // Get the random size for account creation

    void * randomMemory = malloc( randomSize ); // Allocate the memory

    size_t resultOlmCreation = olm_create_account(m_olmAccount, randomMemory, randomSize); // Create the Olm account

    if (resultOlmCreation == olm_error()) {
        return olm_account_last_error(m_olmAccount);
    }

    memset(randomMemory, 0, randomSize); // Set the allocated memory in ram to 0 everywhere

    free(randomMemory);  // Free the memory

    // Get the size for the output puffer for the identity key and save them in
    // the output buffer:
    size_t identityKeysLength = olm_account_identity_keys_length(m_olmAccount);
    char identityKeys[identityKeysLength];
    memset(identityKeys, 0, identityKeysLength);
    olm_account_identity_keys(m_olmAccount, identityKeys, identityKeysLength);

    return identityKeys;
}

/** Uploads an encrypted or unencrypted file.
**/
QString E2ee::uploadFile(QString path, QString uploadUrl, QString token) {

    QFile file(path);

    if(!(file.exists() && file.open(QIODevice::ReadOnly))) {
        return "{ERROR:\"FILE_NOT_FOUND\"}";
    }
    QByteArray data = file.readAll();
    qDebug() << "Data size: " + QString::number(data.size());
    file.close();

    token = "Bearer " + token;
    uploadUrl += "?filename=" + file.fileName();

    QUrl url(uploadUrl);
    QNetworkRequest request(url);
    request.setRawHeader(QByteArray("Authorization"), token.toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkAccessManager manager;
    QNetworkReply* reply = manager.post(request, data);
    QEventLoop loop;
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    QByteArray response = reply->readAll();
    QString dataReply(response);

    return dataReply;
}
