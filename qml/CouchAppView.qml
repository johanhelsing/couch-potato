import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import Qt.labs.handlers 1.0
import QtGamepad 1.0

ShellSurfaceItem {
    id: couchAppView
    //property GamePad gamepad
    //property WaylandCompositor compositor
    property WaylandSeat gamepadSeat: compositor.defaultSeat
    autoCreatePopupItems: true
    sizeFollowsSurface: false
    onWidthChanged: handleSizeChanged()
    onHeightChanged: handleSizeChanged()
    Screen.onDevicePixelRatioChanged: handleSizeChanged()
    function handleSizeChanged() {
        if (!shellSurface) {
            return;
        }
        const dp = Screen.devicePixelRatio;
        const size = Qt.size(width / output.scaleFactor * dp, height / output.scaleFactor * dp);
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
        onAxisRightYChanged: mouseCursor.updateWheelVelocity();
        onButtonXChanged: gamepad.buttonX ? gamepadSeat.sendMousePressEvent(Qt.LeftButton) : gamepadSeat.sendMouseReleaseEvent(Qt.LeftButton)
        onButtonYChanged: gamepad.buttonY ? gamepadSeat.sendMousePressEvent(Qt.RightButton) : gamepadSeat.sendMouseReleaseEvent(Qt.RightButton)
        onButtonL1Changed: gamepad.buttonL1 ? gamepadSeat.sendMousePressEvent(Qt.BackButton) : gamepadSeat.sendMouseReleaseEvent(Qt.BackButton)
    }
    WaylandCursorItem {
        property real cursorSpeed: window.width / 2 // pixels per second
        property real scrollSpeed: window.width * 3 // pixels per second
        property real scrollBufferX: 0
        property real scrollBufferY: 0
        id: mouseCursor
        inputEventsEnabled: false
        seat: gamepadSeat
        function updateWheelVelocity() {
            update();
        }
        function doUpdateWheelVelocity() {
            const deltaTime = 0.016; // assuming smooth 60 fps
            if (!couchAppView.activeFocus)
                return;
            if (gamepad.axisRightX === 0 && gamepad.axisRightY === 0)
                return;
            const deltaX = -gamepad.axisRightX * deltaTime * scrollSpeed;
            const deltaY = -gamepad.axisRightY * deltaTime * scrollSpeed;
            scrollBufferX += deltaX;
            scrollBufferY += deltaY;
            if (Math.abs(scrollBufferY) > 12) {
                gamepadSeat.sendMouseWheelEvent(Qt.Vertical, scrollBufferY);
                scrollBufferY = 0;
            }
            if (Math.abs(scrollBufferX) > 12) {
                gamepadSeat.sendMouseWheelEvent(Qt.Horizontal, scrollBufferX);
                scrollBufferX = 0;
            }
            update(); // keep updating until the axises are left centered
        }
        function updateCursorPosition() {
            update(); // just queue the update, we do the real movement before rendering
        }
        function doUpdateCursorPosition() {
            if (!couchAppView.activeFocus)
                return;
            if (gamepad.axisLeftX === 0 && gamepad.axisLeftY === 0)
                return;
            const deltaTime = 0.016; // assuming smooth 60 fps
            x += gamepad.axisLeftX * mouseCursor.cursorSpeed * deltaTime;
            y += gamepad.axisLeftY * mouseCursor.cursorSpeed * deltaTime;
            var mousePos = Qt.point(x, y);
            mousePos.x /= couchAppView.compositor.defaultOutput.scaleFactor; // because of a bug in sendMouseMoveEvent
            mousePos.y /= couchAppView.compositor.defaultOutput.scaleFactor; // because of a bug in sendMouseMoveEvent
            couchAppView.sendMouseMoveEvent(mousePos);
        }
        Connections {
            target: window
            onBeforeSynchronizing: {
                mouseCursor.doUpdateCursorPosition();
                mouseCursor.doUpdateWheelVelocity();
            }
        }
    }
}
