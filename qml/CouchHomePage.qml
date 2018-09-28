import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FontAwesome 1.0

CouchPage {
    title: "Home"
    icon: FontAwesome.home
    ColumnLayout {
        width: parent.width * 0.66
        spacing: window.height / 25
        CouchButton {
            focus: true
            text: "Close all"
            description: "Close all running apps"
            onClicked: processEngine.killall()
        }
        CouchButton {
            text: "Quit"
            description: "Quit Couch Potato"
            onClicked: Qt.quit()
        }
    }
}
