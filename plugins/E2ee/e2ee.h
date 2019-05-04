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
    Q_INVOKABLE void restoreAccount(QString olmAccountStr, QString key);
    Q_INVOKABLE QString getIdentityKeys();
    Q_INVOKABLE void removeAccount();
    Q_INVOKABLE QString signJsonString(QString jsonStr);
    Q_INVOKABLE QString getOneTimeKeys();

    Q_INVOKABLE bool uploadFile(QString path, QString url, QString token);

public slots:
    void uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal);

signals:
    void uploadFinished(QString reply, QString mimeType, QString fileName, int size);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

};

#endif
