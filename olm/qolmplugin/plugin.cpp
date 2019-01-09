#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "olmtest.h"

void OlmtestPlugin::registerTypes(const char *uri) {
    //@uri Olmtest
    qmlRegisterSingletonType<Olmtest>(uri, 1, 0, "Olmtest", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Olmtest; });
}
