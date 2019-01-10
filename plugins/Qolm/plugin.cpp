#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "qolm.h"

void QolmPlugin::registerTypes(const char *uri) {
    //@uri Qolm
    qmlRegisterSingletonType<Qolm>(uri, 1, 0, "Qolm", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Qolm; });
}
