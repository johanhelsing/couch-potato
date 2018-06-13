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
    Connections {
        enabled: couchAppView.activeFocus
        target: gamepad
//        onButtonUpChanged: gamepadSeat.sendKeyEvent(Qt.Key_Up, gamepad.buttonUp);
//        onButtonDownChanged: gamepadSeat.sendKeyEvent(Qt.Key_Down, gamepad.buttonDown);
//        onButtonLeftChanged: gamepadSeat.sendKeyEvent(Qt.Key_Left, gamepad.buttonLeft);
//        onButtonRightChanged: gamepadSeat.sendKeyEvent(Qt.Key_Right, gamepad.buttonRight);
        onButtonAChanged: gamepadSeat.sendKeyEvent(Qt.Key_Space, gamepad.buttonA);
        onButtonBChanged: gamepadSeat.sendKeyEvent(Qt.Key_Enter, gamepad.buttonB);
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
