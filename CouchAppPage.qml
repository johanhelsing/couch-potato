import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import Qt.labs.handlers 1.0

Page {
    id: page
    property var shellSurface
    signal surfaceDestroyed
    topPadding: page.height / 10
    leftPadding: page.width / 5
    rightPadding: leftPadding
    title: shellSurface.title || shellSurface.toplevel.title || ""
    background: null
    ColumnLayout {
        spacing: page.height / 15
        Label { text: "Switch to " + page.title; font.pixelSize: page.height / 15; font.weight: Font.Light }
        Switch { text: "Emulate mouse"; font.pixelSize: page.height / 25; font.weight: Font.Light }
        Switch { text: "Emulate arrow keys"; font.pixelSize: page.height / 25; font.weight: Font.Light }
        Label { text: "Quit"; font.pixelSize: page.height / 25; font.weight: Font.Light }
    }
    ShellSurfaceItem {
        id: ssItem
        enabled: false
        shellSurface: page.shellSurface
        sizeFollowsSurface: false
        anchors.right: parent.right
        anchors.top: parent.top
        width: page.width / 5
        height: ssItem.implicitHeight / ssItem.implicitWidth * ssItem.width // keep aspect ratio
        onSurfaceDestroyed: shellSurfaces.remove(shellSurface)
    }
}
