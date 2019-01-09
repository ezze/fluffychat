#ifndef OLMTEST_H
#define OLMTEST_H

#include <QObject>

class Olmtest: public QObject {
    Q_OBJECT

public:
    Olmtest();
    ~Olmtest() = default;

    Q_INVOKABLE void speak();
};

#endif
