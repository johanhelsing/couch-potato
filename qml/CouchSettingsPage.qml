import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGamepad 1.0

CouchPage {
    id: settings
    title: "Settings"
    property int currentButton: -1
    readonly property bool configuringButtons: currentButton >= 0
    Keys.onEscapePressed: currentButton = -1;
    property var buttons: [
        { button: GamepadManager.ButtonUp, text: "Up" },
        { button: GamepadManager.ButtonDown, text: "Down" },
        { button: GamepadManager.ButtonLeft, text: "Left" },
        { button: GamepadManager.ButtonRight, text: "Right" },
        { button: GamepadManager.ButtonB, text: "A (Right)" },
        { button: GamepadManager.ButtonA, text: "B (Down)" },
        { button: GamepadManager.ButtonY, text: "X (Up)" },
        { button: GamepadManager.ButtonX, text: "Y (Left)" },
        { button: GamepadManager.ButtonStart, text: "Start" },
        { button: GamepadManager.ButtonSelect, text: "Select" },
        { button: GamepadManager.ButtonL1, text: "L1 (Shoulder)" },
        { button: GamepadManager.ButtonR1, text: "R1 (Shoulder)" },
        { button: GamepadManager.ButtonL2, text: "L2 (Trigger)" },
        { button: GamepadManager.ButtonR2, text: "R2 (Trigger)" },
        { button: GamepadManager.ButtonL3, text: "L3 (Analog stick button)" },
        { button: GamepadManager.ButtonR3, text: "R3 (Analog stick button)" },
        { button: GamepadManager.ButtonGuide, text: "Guide" }
    ]
    Connections {
        target: GamepadManager
        onButtonConfigured: next()
        onConfigurationCanceled: {
            GamepadManager.configureButton(gamepad.deviceId, GamepadManager.ButtonInvalid);
            currentButton = -1;
        }
    }
    Connections {
        target: gamepad
        onAnyButtonChanged: {
            if (!gamepad.anyButton && currentButton >= 0) {
                console.log("Please press", buttons[currentButton].text);
                GamepadManager.configureButton(gamepad.deviceId, buttons[currentButton].button);
            }
        }
    }
    function next() {
        if (currentButton === buttons.length - 1) {
            console.log("Button configuration finished");
            currentButton = -1;
            return;
        }
        ++currentButton;
        if (!gamepad.anyButton) {
            console.log("Please press", buttons[currentButton].text);
            GamepadManager.configureButton(gamepad.deviceId, buttons[currentButton].button);
        }
    }
    ColumnLayout {
        width: parent.width * 0.66
        spacing: window.height / 25
        CouchButton {
            focus: true
            text: "Configure gamepad"
            onClicked: next()
            description: configuringButtons ? "Please press " + buttons[currentButton].text: "Configure all buttons"
        }
        CouchButton {
            text: "Reset gamepad"
            onClicked: GamepadManager.resetConfiguration(gamepad.deviceId);
            description: "Reset button bindings to defaults"
        }
        CouchButton {
            text: "Scale factor " + output.scaleFactor
            onClicked: output.scaleFactor = (output.scaleFactor) % 4 + 1
        }
    }
    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width * 0.33
        Label { text: "Any button"; font.weight: gamepad.anyButton ? Font.Bold : Font.Normal }
        Label {}
        Label { text: "Up"; font.weight: gamepad.buttonUp ? Font.Bold : Font.Normal }
        Label { text: "Down"; font.weight: gamepad.buttonDown ? Font.Bold : Font.Normal }
        Label { text: "Left"; font.weight: gamepad.buttonLeft ? Font.Bold : Font.Normal }
        Label { text: "Right"; font.weight: gamepad.buttonRight ? Font.Bold : Font.Normal }
        Label { text: "A (right)"; font.weight: gamepad.buttonB ? Font.Bold : Font.Normal }
        Label { text: "B (bottom)"; font.weight: gamepad.buttonA ? Font.Bold : Font.Normal }
        Label { text: "X (top)"; font.weight: gamepad.buttonY ? Font.Bold : Font.Normal }
        Label { text: "Y (left)"; font.weight: gamepad.buttonX ? Font.Bold : Font.Normal }
        Label { text: "Start"; font.weight: gamepad.buttonStart ? Font.Bold : Font.Normal }
        Label { text: "Select"; font.weight: gamepad.buttonSelect ? Font.Bold : Font.Normal }
        Label { text: "L1"; font.weight: gamepad.buttonL1 ? Font.Bold : Font.Normal }
        Label { text: "R1"; font.weight: gamepad.buttonR1 ? Font.Bold : Font.Normal }
        Label { text: "L2"; font.weight: gamepad.buttonL2 ? Font.Bold : Font.Normal }
        Label { text: "R2"; font.weight: gamepad.buttonR2 ? Font.Bold : Font.Normal }
        Label { text: "L3"; font.weight: gamepad.buttonL3 ? Font.Bold : Font.Normal }
        Label { text: "R3"; font.weight: gamepad.buttonR3 ? Font.Bold : Font.Normal }
        Label { text: "Guide"; font.weight: gamepad.buttonGuide ? Font.Bold : Font.Normal }
    }
}
