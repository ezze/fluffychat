#ifndef QOLM_H
#define QOLM_H

#include <QObject>
#include <olm/olm.h>
#include <QApplication>
#include <QStringList>
#include <QJsonDocument>
#include <QJsonArray>

class Qolm: public QObject {
    Q_OBJECT

public:
    Qolm();
    ~Qolm() = default;

    Q_INVOKABLE void newDevice(QString device_id);
    Q_INVOKABLE QJsonObject restoreDevice(QJsonObject device);
    
    Q_INVOKABLE QString getPublicFingerprintKey();
    Q_INVOKABLE QString getPublicIdentityKey();
    Q_INVOKABLE QString createOneTimeKey();
    
    Q_INVOKABLE QString encryptMessage(QString body, QString accounts[]);
    Q_INVOKABLE QString encryptFile(QString path, QString accounts[]);
    
};

#endif
