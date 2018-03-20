import QtQuick 2.10
import QtQuick.Layouts 1.3

CouchPage {
    title: "Launch"
    ColumnLayout {
        width: parent.width * 0.66
        spacing: window.height / 25
        CouchButton { text: "Firefox"; focus: true; description: "Web browser"; onClicked: processEngine.run("firefox") }
        CouchButton { text: "weston-simple-egl"; description: "EGL demo application"; onClicked: processEngine.run("weston-simple-egl") }
        CouchButton { text: "Qt Creator"; description: "Qts IDE"; onClicked: processEngine.run("qtcreator") }
        CouchButton { text: "Files"; description: "Browse files using Nautilus"; onClicked: processEngine.run("nautilus") }
    }
}
