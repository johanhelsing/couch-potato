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
    WlShell { onWlShellSurfaceCreated: handleShellSurfaceCreated(wlShellSurface); }
    IviApplication { onIviSurfaceCreated: handleShellSurfaceCreated(iviSurface); }

    WaylandOutput {
        window: CouchWindow {
            shellSurfaces: compositor.shellSurfaces
        }
    }

    Component.onCompleted: processEngine.waylandDisplay = compositor.socketName
}
