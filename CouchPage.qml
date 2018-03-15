import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Page {
    id: page
    leftPadding: window.width / 5
    topPadding: window.height / 25
    ColumnLayout {
        spacing: window.height / 25
        Label { text: "Some option"; font.pixelSize: window.height / 25; font.weight: Font.Light }
        Label { text: "Another option"; font.pixelSize: window.height / 45; font.weight: Font.Light }
        Label { text: "Quit Couch Potato"; font.pixelSize: window.height / 45; font.weight: Font.Light }
    }
}
