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

public:
    E2ee();
    ~E2ee();

    Q_INVOKABLE QString createAccount(QString key);
    Q_INVOKABLE bool restoreAccount(QString olmAccountStr, QString key);
    Q_INVOKABLE QString getIdentityKeys();
    Q_INVOKABLE void removeAccount();
    Q_INVOKABLE QString signJsonString(QString jsonStr);

    /** Returns the public parts of the unpublished one time keys for the account
    **/
    Q_INVOKABLE QString getOneTimeKeys();

    /** Marks all onetimekeys as published **/
    Q_INVOKABLE void markKeysAsPublished();

    /** Generate more one time keys and removes all old unpublished keys **/
    Q_INVOKABLE void generateOneTimeKeys();

    //Q_INVOKABLE QString createOutboundSession(QString identityKey, QString oneTimeKey);
    //
    /** Uploads an encrypted or unencrypted file.
    **/
    Q_INVOKABLE bool uploadFile(QString path, QString url, QString token);

public slots:
    void uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal);

signals:
    void uploadFinished(QString reply, QString mimeType, QString fileName, int size);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

};

#endif
