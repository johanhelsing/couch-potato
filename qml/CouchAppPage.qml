import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0

Page {
    id: page
    property var shellSurface
    property var toplevel: shellSurface ? shellSurface.toplevel : null
    property var appId: toplevel ? toplevel.appId : ""
    property var fullscreen: true
    signal surfaceDestroyed
    signal switchToClicked
    topPadding: page.height / 10
    leftPadding: page.width / 5
    rightPadding: leftPadding
    title: shellSurface.title || (shellSurface.toplevel && shellSurface.toplevel.title) || ""
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
        CouchButton { text: "Resume"; focus: true; onClicked: switchToClicked() }
        CouchButton {
            text: `Fullscreen: ${fullscreen ? "yes" : "no"}`
            onClicked: fullscreen = !fullscreen
        }
        CouchButton { text: "Close"; onClicked: page.closeShellSurface() }
    }
    ShellSurfaceItem {
        id: ssItem
        enabled: false
        shellSurface: page.shellSurface
        sizeFollowsSurface: false
        autoCreatePopupItems: false
        anchors.right: parent.right
        anchors.top: parent.top
        width: page.width / 5
        height: ssItem.implicitHeight / ssItem.implicitWidth * ssItem.width // keep aspect ratio
        onSurfaceDestroyed: page.surfaceDestroyed()
    }
}
