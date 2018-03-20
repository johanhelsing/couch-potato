import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import Qt.labs.handlers 1.0

ShellSurfaceItem {
    id: couchAppView
    sizeFollowsSurface: false
    onWidthChanged: handleSizeChanged()
    onHeightChanged: handleSizeChanged()
    function handleSizeChanged() {
        if (!shellSurface) {
            return;
        }
        if (shellSurface.toplevel) {
            shellSurface.toplevel.sendFullscreen(Qt.size(width, height));
        } else if (shellSurface.sendConfigure) {
            shellSurface.sendConfigure(Qt.size(width, height), 0);
        } else {
            console.warn("don't know how to resize the surface");
        }
    }
    Component.onCompleted: handleSizeChanged();
    onShellSurfaceChanged: handleSizeChanged();
    moveItem: noop // hack to disable window moving
    Item { id: noop }
}
