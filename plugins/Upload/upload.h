#ifndef UPLOAD_H
#define UPLOAD_H

#include <QObject>
#include <QJsonObject>

class Upload: public QObject {
    Q_OBJECT

private:
public:
    Upload();

    // TODO: More detailed comments for doxygen

    /** Uploads an encrypted or unencrypted file. Returns false if the given file
     * does not exist or can not be opened.
    **/
    Q_INVOKABLE bool uploadFile(QString path, QString url, QString token);

public slots:
    void uploadProgressSlot(qint64 bytesSent, qint64 bytesTotal);

signals:
    void uploadFinished(QString reply, QString mimeType, QString fileName, int size);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

};

#endif
