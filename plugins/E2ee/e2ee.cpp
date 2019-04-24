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
QString E2ee::getAccount(QString matrix_id) {

    // Check if there is already an existing persistent Olm account
    QFile olmFile("olm.data");
    if (olmFile.exists()) {
        if (olmFile.open(QIODevice::ReadOnly)) {
            QDataStream in(&olmFile);
            in>>m_olmAccount;
        }
        qDebug() << "Restore old olm account";
    }
    else {  // If not, then create a new Olm account
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

        if(olmFile.open(QIODevice::WriteOnly)){
            QDataStream out(&olmFile);
            //out<<m_olmAccount;
        }
        qDebug() << "Create and save new olm account";
    }

    olmFile.close();

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
