import QtQuick 2.10
import QtQuick.Layouts 1.3
import FontAwesome 1.0

CouchPage {
    title: "Launch"
    icon: FontAwesome.rocket
    function launch(executable) { processEngine.run(executable); }
    ColumnLayout {
        width: parent.width * 0.66
        spacing: window.height / 25
        CouchButton { text: "Web browser"; description: "Browse the web with Epiphany"; onClicked: launch("epiphany"); focus: true }
        CouchButton { text: "Files"; description: "Browse files using Nautilus"; onClicked: launch("nautilus") }
        CouchButton { text: "Qt Creator"; description: "Qts IDE"; onClicked: launch("qtcreator") }
        CouchButton { text: "weston-simple-egl"; description: "EGL demo application"; onClicked: launch("weston-simple-egl") }
        CouchButton { text: "window focus test"; description: "green on focus"; onClicked: launch("qmlscenedev /home/johan/qmltests/hasfocus.qml") }
        CouchButton { text: "clickdot test"; description: "click to move crosshair"; onClicked: launch("qmlscenedev /home/johan/qmltests/clickdot.qml") }
    }
}
