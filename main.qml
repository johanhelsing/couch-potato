import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1
import QtGraphicalEffects 1.0
import Qt.labs.handlers 1.0

WaylandCompositor {
    id: compositor
    WaylandOutput {
        window: ApplicationWindow {
            id: window
            property real leftPadding: window.width / 5
            property ShellSurface currentShellSurface: swipeView.currentItem.shellSurface || null
            visible: true
            width: 1280
            height: 720
            title: qsTr("Couch Potato")
            Shortcut {
                sequence: "tab"
                onActivated: overlay.enabled = !overlay.enabled
            }
            Page { // needed wrapper for global keys to work
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
                    Component {
                        id: mainAppViewComponent //should probably moved to separate file?
                        ShellSurfaceItem {
                            id: ssItem
                            sizeFollowsSurface: false
                            onWidthChanged: handleSizeChanged()
                            onHeightChanged: handleSizeChanged()
                            function handleSizeChanged() {
                                if (!shellSurface) {
                                    console.warn("No shell surface, how did we get here?", shellSurface);
                                    return
                                }
                                if (shellSurface.toplevel) {
                                    shellSurface.toplevel.sendFullscreen(Qt.size(width, height));
                                } else if (shellSurface.sendConfigure){
                                    shellSurface.sendConfigure(0, Qt.size(width, height));
                                } else {
                                    console.warn("don't know how to resize the surface");
                                }
                            }
                            Component.onCompleted: handleSizeChanged();
                        }
                    }

                    id: appViewStack
                    property ShellSurface activeSurface: window.currentShellSurface
                    onActiveSurfaceChanged: {
                        replace(mainAppViewComponent, {shellSurface: activeSurface});
                    }
                }

                Page {
                    anchors.fill: parent
                    id: overlay
                    opacity: enabled ? 1 : 0
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
                            CouchPage { title: "Settings" }
                            CouchPage { title: "Launch" }
                            CouchPage { title: "Browser" }
                            Repeater {
                                model: shellSurfaces
                                Page {
                                    id: page
                                    property var shellSurface: modelData
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
    }
    ListModel { id: shellSurfaces }
    function handleShellSurfaceCreated(shellSurface) {
        console.log("shell surface created", shellSurface)
        shellSurfaces.append({shellSurface: shellSurface});
        swipeView.currentIndex = swipeView.count - 1;
    }
    XdgShellV6 { onToplevelCreated: handleShellSurfaceCreated(xdgSurface); }
    XdgShellV5 { onXdgSurfaceCreated: handleShellSurfaceCreated(xdgSurface); }
    WlShell { onWlShellSurfaceCreated: handleShellSurfaceCreated(wlShellSurface); }
    IviApplication { onIviSurfaceCreated: handleShellSurfaceCreated(iviSurface); }
}
