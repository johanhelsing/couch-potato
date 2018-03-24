import QtQuick 2.10
import QtWayland.Compositor 1.1

WaylandCompositor {
    id: compositor
    property ListModel shellSurfaces: ListModel {}

    function handleShellSurfaceCreated(shellSurface) {
        compositor.shellSurfaces.append({shellSurface: shellSurface});
    }

    XdgShellV6 { onToplevelCreated: handleShellSurfaceCreated(xdgSurface); }
    XdgShellV5 { onXdgSurfaceCreated: handleShellSurfaceCreated(xdgSurface); }
    WlShell { onWlShellSurfaceCreated: handleShellSurfaceCreated(shellSurface); }
    IviApplication { onIviSurfaceCreated: handleShellSurfaceCreated(iviSurface); }

    WaylandOutput {
        id: output
        scaleFactor: 2
        window: CouchWindow {
            shellSurfaces: compositor.shellSurfaces
        }
    }

    Component.onCompleted: processEngine.waylandDisplay = compositor.socketName
}
