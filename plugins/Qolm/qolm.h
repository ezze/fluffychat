#ifndef QOLM_H
#define QOLM_H

#include <QObject>
#include <olm/olm.h>

class Qolm: public QObject {
    Q_OBJECT

public:
    Qolm();
    ~Qolm() = default;

    Q_INVOKABLE void speak();
};

#endif
