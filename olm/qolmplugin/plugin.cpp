#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "qolmplugin.h"

void QolmpluginPlugin::registerTypes(const char *uri) {
    //@uri Olmtest
    qmlRegisterSingletonType<Qolmplugin>(uri, 1, 0, "Qolmplugin", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Qolmplugin; });
}
