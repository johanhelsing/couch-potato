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
    function closeShellSurface() {
        if (shellSurface.toplevel) {
            shellSurface.toplevel.sendClose();
        } else {
            shellSurface.surface.client.close();
        }
    }
    ColumnLayout {
        spacing: page.height / 15
        CouchButton { text: "Switch to " + page.title; focus: true; onClicked: console.log("todo: switch to the application"); }
        CouchButton { text: "Emulate mouse" }
        CouchButton { text: "Emulate arrow keys" }
        CouchButton { text: "Close"; onClicked: page.closeShellSurface() }
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
        onSurfaceDestroyed: page.surfaceDestroyed()
    }
}
