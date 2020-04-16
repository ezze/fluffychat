#ifndef UPLOADPLUGIN_H
#define UPLOADPLUGIN_H

#include <QQmlExtensionPlugin>

class UploadPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif
