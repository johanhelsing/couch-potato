import QtQuick 2.10
import QtQuick.Layouts 1.3

CouchPage {
    title: "Launch"
    function launch(executable) { processEngine.run(executable); }
    ColumnLayout {
        width: parent.width * 0.66
        spacing: window.height / 25
        CouchButton { text: "Firefox"; description: "Web browser"; onClicked: launch("firefox"); focus: true }
        CouchButton { text: "weston-simple-egl"; description: "EGL demo application"; onClicked: launch("weston-simple-egl") }
        CouchButton { text: "Qt Creator"; description: "Qts IDE"; onClicked: launch("qtcreator") }
        CouchButton { text: "Files"; description: "Browse files using Nautilus"; onClicked: launch("nautilus") }
    }
}
