import QtQuick 2.10
import QtWayland.Compositor 1.3

WaylandCompositor {
    id: compositor
    property ListModel toplevels: ListModel {}

    function handleShellSurfaceCreated(shSurface) {
        console.log("shell surface created", shSurface)
        compositor.toplevels.append({
            shSurface,
            fullscreen: true
        });
    }

    XdgShell { onToplevelCreated: handleShellSurfaceCreated(xdgSurface); }
    XdgDecorationManagerV1 { preferredMode: XdgToplevel.ServerSideDecoration }

    // legacy shells
    XdgShellV6 { onToplevelCreated: handleShellSurfaceCreated(xdgSurface); }
    XdgShellV5 { onXdgSurfaceCreated: handleShellSurfaceCreated(xdgSurface); }
    WlShell { onWlShellSurfaceCreated: handleShellSurfaceCreated(shellSurface); }
    IviApplication { onIviSurfaceCreated: handleShellSurfaceCreated(iviSurface); }

    WaylandOutput {
        id: output
        scaleFactor: 2
        sizeFollowsWindow: true
        window: CouchWindow {
            toplevels: compositor.toplevels
        }
    }

    Component.onCompleted: processEngine.waylandDisplay = compositor.socketName
}
