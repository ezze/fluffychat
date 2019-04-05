#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "e2ee.h"

void E2eePlugin::registerTypes(const char *uri) {
    //@uri E2ee
    qmlRegisterSingletonType<E2ee>(uri, 1, 0, "E2ee", [](QQmlEngine*, QJSEngine*) -> QObject* { return new E2ee; });
}
