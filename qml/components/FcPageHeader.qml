import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

PageHeader {
    id: header
    title: i18n.tr('FluffyChat')

    StyleHints {
        foregroundColor: settings.mainColor
        textSize: title.indexOf("\n") !== -1 ? Label.Medium : Label.Large
    }
}
