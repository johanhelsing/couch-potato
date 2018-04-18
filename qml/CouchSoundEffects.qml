pragma Singleton

import QtQuick 2.4
import QtMultimedia 5.8

QtObject {
    readonly property SoundEffect menuHover: SoundEffect {
        source: "little-thing.wav"
    }
}
