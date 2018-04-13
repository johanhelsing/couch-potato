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
        onAxisLeftXChanged: mouseCursor.updateCursorPosition();
        onAxisLeftYChanged: mouseCursor.updateCursorPosition();
        onButtonXChanged: gamepad.buttonX ? gamepadSeat.sendMousePressEvent(Qt.LeftButton) : gamepadSeat.sendMouseReleaseEvent(Qt.LeftButton)
        onButtonYChanged: gamepad.buttonX ? gamepadSeat.sendMousePressEvent(Qt.RightButton) : gamepadSeat.sendMouseReleaseEvent(Qt.RightButton)
    }
    WaylandCursorItem {
        property real cursorSpeed: window.width / 2 // pixels per second
        id: mouseCursor
        inputEventsEnabled: false
        seat: gamepadSeat
        function updateCursorPosition() {
            update(); // just queue the update, we do the real movement before rendering
        }
        function doUpdateCursorPosition() {
            const deltaTime = 0.016; // assuming smooth 60 fps
            x += gamepad.axisLeftX * mouseCursor.cursorSpeed * deltaTime;
            y += gamepad.axisLeftY * mouseCursor.cursorSpeed * deltaTime;
            var mousePos = Qt.point(x, y);
            mousePos /= couchAppView.compositor.defaultOutput.scaleFactor; // because of a bug in sendMouseMoveEvent
            couchAppView.sendMouseMoveEvent(mousePos);
            couchAppView.sendMouseMoveEvent(mousePos);
        }
        Connections {
            target: window
            onBeforeSynchronizing: mouseCursor.doUpdateCursorPosition();
        }
    }
}
