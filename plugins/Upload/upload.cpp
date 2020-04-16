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

#include "upload.h"

Upload::Upload()
{

}

QString logError(QString errorMsg)
{
    QString logMsg = "🐞[Upload] " + errorMsg;
    qDebug() << logMsg;
    return "";
}

bool Upload::uploadFile(QString path, QString uploadUrl, QString token)
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