import QtQuick 2.10
import QtQuick.Layouts 1.3

CouchPage {
    title: "Launch"
    ColumnLayout {
        width: parent.width * 0.66
        spacing: window.height / 25
        CouchButton { text: "Firefox"; focus: true; description: "Web browser" }
        CouchButton { text: "weston-simple-egl"; description: "EGL demo application" }
        CouchButton { text: "Qt Creator"; description: "Qts IDE" }
        CouchButton { text: "Files"; description: "Browse files using Nautilus" }
    }
}
