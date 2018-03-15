import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWayland.Compositor 1.1

WaylandCompositor {
    id: compositor
    WaylandOutput {
        window: ApplicationWindow {
            id: window
            property real leftPadding: window.width / 5
            visible: true
            width: 640
            height: 480
            title: qsTr("Tabs")

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
                        ToolButton {
                            property Page page: swipeView.contentChildren[index]
                            x: (index - swipeView.currentIndex) * iconBar.spacing + window.leftPadding - width/2
                            text: page.title[0]
                            font.pixelSize: window.height / 20
                            onClicked: swipeView.currentIndex = index
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
                            leftPadding: page.width / 5
                            rightPadding: leftPadding
                            title: shellSurface.title || shellSurface.toplevel.title || ""
                            ColumnLayout {
                                spacing: page.height / 15
                                Label { text: "Switch to " + page.title; font.pixelSize: page.height / 15; font.weight: Font.Light }
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
                            }
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
