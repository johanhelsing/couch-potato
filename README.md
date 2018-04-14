# Couch potato

A Wayland compositor written with Qt.

The goal is to have a compositor that can be usable on the couch without
requiring a mouse or squinting with your eyes.

Mouse (and keyboard) events are faked by generating them when pressing a
gamepad. This means all applications will think they are actually receiving
mouse and keyboard events (so no need to modify existing applications).

The user interface also supports navigation by regular keyboard (and mouse!),
so a gamepad is not strictly required.

## Dependencies

Qt 5.11 with the following modules:

- QtWayland
- QtDeclarative
- QtMultimedia
- QtGamepad
- QtQuickControls 2
- QtGraphicalEffects
- Qbs

Arch linux: `pacman -S qt5-wayland qt5-multimedia qt5-quickcontrols2 qt5-gamepad qt5-graphicaleffects qbs`

Also, some patches to QtWayland are necessary, they will hopefully be merged
in 5.12:

- Emulated mouse events: https://codereview.qt-project.org/#/c/226107/ and https://codereview.qt-project.org/#/c/226108/
- Emulated keyboard events: https://codereview.qt-project.org/#/c/224749/
- Fix mouse events for scale factor != 1: https://codereview.qt-project.org/#/c/224760/

## Building

### Qt Creator

Just open couch-potato.qbs

### Command line

If you haven't done so, make sure qbs is set up correctly:

    $ qbs setup-qt --detect
    Creating profile 'qt-5-11-0'.
    Setting profile 'gcc' as the base profile for this profile.
    Creating profile 'qt-4-8-7'.
    Setting profile 'gcc' as the base profile for this profile.

Then, in the project directory to build and run the compositor:

    $ qbs run profile:qt-5-11-0

