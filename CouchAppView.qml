import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import Qt.labs.handlers 1.0
import QtGamepad 1.0

ShellSurfaceItem {
    id: couchAppView
    //property GamePad gamepad
    //property WaylandCompositor compositor
    property WaylandSeat gamepadSeat: compositor.defaultSeat
    sizeFollowsSurface: false
    onWidthChanged: handleSizeChanged()
    onHeightChanged: handleSizeChanged()
    function handleSizeChanged() {
        if (!shellSurface) {
            return;
        }
        var size = Qt.size(width / output.scaleFactor, height / output.scaleFactor);
        if (shellSurface.toplevel) {
            shellSurface.toplevel.sendFullscreen(size);
        } else if (shellSurface.sendConfigure) {
            shellSurface.sendConfigure(size, 0);
        } else {
            console.warn("don't know how to resize the surface");
        }
    }
    Component.onCompleted: handleSizeChanged();
    onShellSurfaceChanged: handleSizeChanged();
    moveItem: noop // hack to disable window moving
    Item { id: noop }
    property var keyCodes: ({
        up: 111,
        down: 116,
        left: 113,
        right: 114,
        space: 65,
        enter: 36,
    })
    function sendKey(keyCode, pressed) {
        if (pressed) {
            gamepadSeat.sendKeyPressEvent(keyCode);
        } else {
            gamepadSeat.sendKeyReleaseEvent(keyCode);
        }
    }
    Connections {
        enabled: couchAppView.activeFocus
        target: gamepad
        onButtonUpChanged: sendKey(keyCodes.up, gamepad.buttonUp);
        onButtonDownChanged: sendKey(keyCodes.down, gamepad.buttonDown);
        onButtonLeftChanged: sendKey(keyCodes.left, gamepad.buttonLeft);
        onButtonRightChanged: sendKey(keyCodes.right, gamepad.buttonRight);
        onButtonAChanged: sendKey(keyCodes.space, gamepad.buttonA);
        onButtonBChanged: sendKey(keyCodes.enter, gamepad.buttonB);
    }
}
