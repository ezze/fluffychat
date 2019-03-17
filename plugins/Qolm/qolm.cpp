#include <QDebug>
#include <olm/olm.h>

#include "qolm.h"

Qolm::Qolm() {

}

void Qolm::speak() {
    qDebug() << "hello world!";
}
