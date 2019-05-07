#include "pushhelper.h"
#include "i18n.h"
#include <QApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QStringList>


PushHelper::PushHelper(const QString appId, const QString infile, const QString outfile, QObject *parent) : QObject(parent),
mInfile(infile), mOutfile(outfile)
{
    connect(&mPushClient, SIGNAL(persistentCleared()),
    this, SLOT(notificationDismissed()));

    mPushClient.setAppId(appId);
    mPushClient.registerApp(appId);
}

void PushHelper::process() {
    QString tag = "";

    QJsonObject pushMessage = readPushMessage(mInfile);
    mPostalMessage = pushToPostalMessage(pushMessage, tag);
    if (!tag.isEmpty()) {
        dismissNotification(tag);
    }

    // persistentCleared not called!
    notificationDismissed();
}

void PushHelper::notificationDismissed() {
    writePostalMessage(mPostalMessage, mOutfile);
    Q_EMIT done(); // Why does this not work?
}

QJsonObject PushHelper::readPushMessage(const QString &filename) {
    QFile file(filename);
    file.open(QIODevice::ReadOnly | QIODevice::Text);

    QString val = file.readAll();
    file.close();
    return QJsonDocument::fromJson(val.toUtf8()).object();
}

void PushHelper::writePostalMessage(const QJsonObject &postalMessage, const QString &filename) {
    QFile out;
    out.setFileName(filename);
    out.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);

    QTextStream(&out) << QJsonDocument(postalMessage).toJson();
    out.close();
}

void PushHelper::dismissNotification(const QString &tag) {
    QStringList tags;
    tags << tag;
    mPushClient.clearPersistent(tags);
}

QJsonObject PushHelper::pushToPostalMessage(const QJsonObject &pushMessage, QString &tag) {

    // Get the matrix-message object
    QJsonObject push;
    if (pushMessage.contains("message")) {
        push = pushMessage["message"].toObject();
    }


    // Unread count
    qint32 unread = 0;
    if (push.contains("counts")) {
        const QJsonObject counts = push["counts"].toObject();
        if (counts.contains("unread")) {
            unread = qint32(counts["unread"].toInt());
        }
    }

    // Get the id and clear persistent notifications
    QString id = QString("");
    if (push.contains("room_id")) {
        id = push["room_id"].toString();

        // Clear tag
        if (!id.isEmpty()) {
            dismissNotification(id);
        }
    }

    // Get the type and return if it is not a supported type
    QString type = QString("");
    if ( push.contains("type") ) {
        type = push["type"].toString();
    }

    // If there is no unread message, then this is the signal to just clear persistent
    // notifications with this id and reset the unread counter
    if ( unread == 0 || !(push.contains("event_id") && !push["event_id"].toString().isEmpty()) ) {
        QStringList tags = mPushClient.getNotifications();
        if ( unread == 0 ) {
            mPushClient.clearPersistent(tags);
        }
        //The notification object to be passed to Postal
        QJsonObject notification{
            {"tag", id},
            {"emblem-counter", QJsonObject{
                {"count", unread},
                {"visible", false},
            }},
        };
        return QJsonObject{
            {"message", push}, // Include the original matrix push object to be delivered to the app
            {"notification", notification}
        };
    }


    // First try the sender displayname otherwise fallback
    // to the full length username type string thingy
    QString sender = QString("");
    if (push.contains("sender_display_name")) {
        sender = push["sender_display_name"].toString();
    }
    else if (push.contains("sender") && !push["sender"].toString().isEmpty()) {
        sender = push["sender"].toString();
    }


    // The summary will be the room name or the sender
    QString summary = QString(N_("Unknown"));
    if (push.contains("room_name") && !push["room_name"].toString().isEmpty() ) {
        summary = push["room_name"].toString();
    }
    else if(push.contains("sender_display_name") && !push["sender_display_name"].toString().isEmpty() ) {
        summary = push["sender_display_name"].toString();
    }
    else if(push.contains("sender") && !push["sender"].toString().isEmpty() ) {
        summary = push["sender"].toString();
    }


    // Get the body
    QString body = QString(N_("New message"));
    if (type == QStringLiteral("m.room.message")) {
        if (push.contains("content")) {
            const QJsonObject content = push["content"].toObject();
            if (content.contains("body")) {
                body = content["body"].toString();
            }
        }
    }
    else if (type == QStringLiteral("m.room.encrypted")) {
        body = QString(N_("New encrypted message"));
    }
    else if (type == QStringLiteral("m.room.member")) {
        body = QString(N_("New member event"));
        if (push.contains("user_is_target") && push["user_is_target"].toBool()) {
            if (push.contains("content")) {
                const QJsonObject content = push["content"].toObject();
                if (content.contains("body")) {
                    if (content.contains("membership") && content["membership"].toString() == QString("invite"))
                    body = QString(N_("You were invited to chat"));
                }
            }
        }
    }


    // Direct chat or not?
    bool directChat = false;
    if (push.contains("room_name") && push["room_name"].toString() != sender) {
        body = sender + QString(": ") + body;
        directChat = true;
    }

    // Get the icon
    QString icon = QString("contact-group");
    if (directChat) icon = QString("contact");

    //The notification object to be passed to Postal
    QJsonObject notification{
        {"tag", id},
        {"card", QJsonObject{
            {"summary", summary},
            {"body", body},
            {"popup", true},
            {"persist", true},
            {"actions", QJsonArray() << QString("fluffychat://%1").arg(id)},
            {"icon", icon},
        }},
        {"emblem-counter", QJsonObject{
            {"count", unread},
            {"visible", unread > 0},
        }},
        {"sound", true},
        {"vibrate", true},
    };

    return QJsonObject{
        {"message", push}, // Include the original matrix push object to be delivered to the app
        {"notification", notification}
    };
}
