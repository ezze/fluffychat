#ifndef QOLMPLUGINPLUGIN_H
#define QOLMPLUGINPLUGIN_H

#include <QQmlExtensionPlugin>

class QolmpluginPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif
