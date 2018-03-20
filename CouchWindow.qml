import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import Qt.labs.handlers 1.0

ApplicationWindow {
    id: window
    property ListModel shellSurfaces
    property real leftPadding: window.width / 5
    property ShellSurface currentShellSurface: swipeView.currentItem.shellSurface || null
    visible: true
    width: 1280
    height: 720
    title: qsTr("Couch Potato")
    Shortcut {
        sequence: "escape"
        onActivated: overlay.enabled = !overlay.enabled || !currentShellSurface
    }
    Page { // needed wrapper for global keys to work
        focus: true
        anchors.fill: parent
        StackView {
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

            anchors.fill: parent
            id: appViewStack
            property ShellSurface activeSurface: window.currentShellSurface
            onActiveSurfaceChanged: {
                if (activeSurface) {
                    replace("CouchAppView.qml", {shellSurface: activeSurface});
                }
            }
        }

        Page {
            focus: true
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
                                    anchors.margins: width / 10
                                    shellSurface: modelData
                                    sizeFollowsSurface: false
                                    anchors.fill: parent
                                }
                            }
                            Label {
                                anchors.centerIn: parent
                                font.pixelSize: window.height / 20
                                font.weight: Font.Bold
                                text: page.title[0] || ""
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
                    focus: true
                    CouchHomePage {}
                    CouchLaunchPage {}
                    CouchSettingsPage {}
                    Repeater {
                        model: shellSurfaces
                        CouchAppPage {
                            id: couchAppPage
                            shellSurface: modelData
                            onSurfaceDestroyed: shellSurfaces.remove(index)
                            onSwitchToClicked: { overlay.enabled = false; appViewStack.forceActiveFocus() }
                            Component.onCompleted: swipeView.currentIndex = SwipeView.index
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
