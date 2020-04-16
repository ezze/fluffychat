#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "upload.h"

void UploadPlugin::registerTypes(const char *uri) {
    //@uri Upload
    qmlRegisterSingletonType<Upload>(uri, 1, 0, "Upload", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Upload; });
}
