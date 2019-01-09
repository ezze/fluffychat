#include <QDebug>

#include "qolmplugin.h"

Qolmplugin::Qolmplugin() {

}

void Qolmplugin::speak() {
    qDebug() << "hello world!";
}
