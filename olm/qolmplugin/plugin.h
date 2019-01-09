#ifndef OLMTESTPLUGIN_H
#define OLMTESTPLUGIN_H

#include <QQmlExtensionPlugin>

class OlmtestPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif
