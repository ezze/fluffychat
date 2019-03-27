#ifndef E2EEPLUGIN_H
#define E2EEPLUGIN_H

#include <QQmlExtensionPlugin>

class E2eePlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif
