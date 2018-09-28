import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import QtGamepad 1.0
import QtQuick.Window 2.7
import FontAwesome 1.0

ApplicationWindow {
    id: window
    property ListModel shellSurfaces
    property real leftPadding: window.width / 5
    property ShellSurface currentShellSurface: swipeView.currentItem.shellSurface || null
    visible: true
    width: 1280
    height: 720
    title: qsTr("Couch Potato")
    function toggleOverlay() {
        overlay.enabled = !overlay.enabled || !currentShellSurface
    }
    function toggleFullscreen() {
        window.visibility = window.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen;
    }

    Gamepad {
        property bool anyButton: buttonUp || buttonDown || buttonLeft || buttonRight ||
        buttonB || buttonA || buttonY || buttonX ||
        buttonStart || buttonSelect || buttonGuide ||
        buttonL1 || buttonR1 || buttonL2 || buttonR2 || buttonL3 || buttonR3
        id: gamepad
        deviceId: GamepadManager.connectedGamepads[0] || -1
        onButtonAChanged: if (buttonA) console.log("gamepad A pressed");
        onButtonBChanged: if (buttonB) console.log("gamepad B pressed");
        onButtonXChanged: if (buttonX) console.log("gamepad X pressed");
        onButtonYChanged: if (buttonY) console.log("gamepad Y pressed");
        onButtonGuideChanged: if (buttonGuide) toggleOverlay()
        onButtonStartChanged: if (buttonStart) toggleOverlay()
    }

    Connections {
        target: GamepadManager
        onGamepadConnected: gamepad.deviceId = deviceId
    }

    GamepadKeyNavigation {
        id: gamepadKeyNavigation
        gamepad: gamepad
        active: !settingsPage.configuringButtons && overlay.enabled
        buttonAKey: Qt.Key_Space
        buttonGuideKey: Qt.Key_Escape
        buttonStartKey: Qt.Key_Escape
    }

    Shortcut {
        sequence: "escape"
        onActivated: toggleOverlay()
    }

    Shortcut {
        sequence: "ctrl+f"
        onActivated: toggleFullscreen()
    }

    Shortcut {
        sequence: "ctrl+q"
        onActivated: Qt.quit()
    }

    Page { // needed wrapper for global keys to work
        anchors.fill: parent
        StackView {
            id: appViewStack
            property ShellSurface activeSurface: window.currentShellSurface
            anchors.fill: parent
            Connections {
                target: overlay
                onEnabledChanged: {
                    if (!overlay.enabled && appViewStack.currentItem.takeFocus) {
                        appViewStack.currentItem.takeFocus();
                    }
                }
            }

            onActiveSurfaceChanged: {
                if (activeSurface) {
                    replace("CouchAppView.qml", {shellSurface: activeSurface});
                } else {
                    overlay.enabled = true;
                }
            }
            replaceEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                }
            }
            replaceExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    to: 0
                    duration: 300
                }
            }
        }

        Page {
            anchors.fill: parent
            id: overlay
            opacity: enabled ? 1 : 0
            onEnabledChanged: if (enabled) forceActiveFocus()
            background: FastBlur {
                source: appViewStack
                radius: 32
                Rectangle {
                    anchors.fill: parent
                    color: "#88ffffff"
                }
            }
            ColumnLayout {
                anchors.fill: parent

                Label {
                    text: swipeView.currentItem.title
                    font.pixelSize: window.height / 15
                    font.weight: Font.ExtraLight
                    padding: font.pixelSize / 2
                }

                Item {
                    id: iconBar
                    property int currentIndex: swipeView.currentIndex
                    Layout.fillWidth: true
                    height: window.height / 8
                    property real spacing: height * 1.3
                    Repeater {
                        model: swipeView.count
                        Item {
                            width: window.width / window.height * iconBar.height
                            height: iconBar.height
                            property Page page: swipeView.contentChildren[index]
                            x: (index - swipeView.currentIndex) * iconBar.spacing + window.leftPadding - width/2
                            TapHandler {
                                onTapped: swipeView.currentIndex = index
                            }
                            Repeater {
                                model: page.shellSurface
                                ShellSurfaceItem {
                                    inputEventsEnabled: false
                                    enabled: false
                                    shellSurface: modelData
                                    sizeFollowsSurface: false
                                    anchors.fill: parent
                                }
                            }
                            Label {
                                anchors.centerIn: parent
                                text: page.icon || page.title[0] || ""
                                font.pixelSize: window.height / 20
                                font.weight: page.icon ? Font.Normal : Font.Bold
                                font.family: page.icon ? FontAwesome.fontFamily : "arial"
                            }
                            scale: swipeView.currentIndex === index ? 1 : 0.5

                            Behavior on x {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutQuad
                                }
                            }
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                SwipeView {
                    id: swipeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    CouchHomePage {}
                    CouchLaunchPage {}
                    CouchSettingsPage { id: settingsPage }
                    Repeater {
                        model: shellSurfaces
                        CouchAppPage {
                            id: couchAppPage
                            shellSurface: modelData
                            onSurfaceDestroyed: shellSurfaces.remove(index)
                            onSwitchToClicked: { window.toggleOverlay() }
                            Component.onCompleted: { swipeView.currentIndex = SwipeView.index; overlay.enabled = false }
                        }
                    }
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
