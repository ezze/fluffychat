#ifndef QOLMPLUGIN_H
#define QOLMPLUGIN_H

#include <QObject>

class Qolmplugin: public QObject {
    Q_OBJECT

public:
    Qolmplugin();
    ~Qolmplugin() = default;

    Q_INVOKABLE void speak();
};

#endif
