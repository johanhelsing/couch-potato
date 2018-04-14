import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "."

AbstractButton {
    id: button
    font.weight: Font.Light
    font.pixelSize: window.height / 25
    onActiveFocusChanged: if (activeFocus) CouchSoundEffects.menuHover.play()
    property int index: {
        for (var i = 0; i < parent.children.length; ++i) {
            if (parent.children[i] === this) { return i; }
        }
    }
    property string description: ""
    KeyNavigation.up: parent.children[index-1] || parent.children[parent.children.length-1]
    KeyNavigation.down: parent.children[index+1] || parent.children[0];
    contentItem: Item {
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        implicitHeight: label.implicitHeight + (button.activeFocus ? descriptionText.implicitHeight : 0)
        implicitWidth: descriptionText.width
        Label {
            id: label
            text: button.text
            font: button.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            scale: button.activeFocus ? 1 : 0.5
            transformOrigin: Item.Left
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Label {
            width: button.parent.width * 0.66
            id: descriptionText
            opacity: button.activeFocus ? 1 : 0
            text: description
            font.pixelSize: button.font.pixelSize / 2
            verticalAlignment: Text.AlignVCenter
            anchors.top: label.bottom
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
