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

    Q_INVOKABLE QString createAccount();

    Q_INVOKABLE bool uploadFile(QString path, QString url, QString token);

    /*Q_INVOKABLE void newDevice(QString device_id);
    Q_INVOKABLE QJsonObject restoreDevice(QJsonObject device);

    Q_INVOKABLE QString getPublicFingerprintKey();
    Q_INVOKABLE QString getPublicIdentityKey();
    Q_INVOKABLE QString createOneTimeKey();

    Q_INVOKABLE QString encryptMessage(QString body, QString accounts[]);
    Q_INVOKABLE QString encryptFile(QString path, QString accounts[]);*/

signals:
    void uploadFinished(QString reply, QString mimeType, QString fileName, int size);

};

#endif
