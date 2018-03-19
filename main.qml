import QtQuick 2.10
import QtWayland.Compositor 1.1

WaylandCompositor {
    id: compositor
    WaylandOutput {
        window: CouchWindow {
        }
    }
    ListModel { id: shellSurfaces }
    function handleShellSurfaceCreated(shellSurface) {
        console.log("shell surface created", shellSurface)
        shellSurfaces.append({shellSurface: shellSurface});
//        swipeView.currentIndex = swipeView.count - 1;
    }
    XdgShellV6 { onToplevelCreated: handleShellSurfaceCreated(xdgSurface); }
    XdgShellV5 { onXdgSurfaceCreated: handleShellSurfaceCreated(xdgSurface); }
    WlShell { onWlShellSurfaceCreated: handleShellSurfaceCreated(wlShellSurface); }
    IviApplication { onIviSurfaceCreated: handleShellSurfaceCreated(iviSurface); }
}
