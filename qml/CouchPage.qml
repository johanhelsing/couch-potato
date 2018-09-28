import QtQuick 2.10
import QtQuick.Controls 2.3

Page {
    property real bigFontSize: window.height / 25
    property real smallFontSize: window.height / 45
    property string icon: ""
    leftPadding: window.width / 5
    rightPadding: leftPadding
    topPadding: window.height / 25
    background: null
    Component.onCompleted: forceActiveFocus()
}
