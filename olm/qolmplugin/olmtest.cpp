#include <QDebug>

#include "olmtest.h"

Olmtest::Olmtest() {

}

void Olmtest::speak() {
    qDebug() << "hello world!";
}
