import QtQuick 6.0

// ClockWidget.qml
// A self-contained component that displays the current time.

Text {
    id: clockText
    color: "#FFFFFF" // Default color, can be overridden
    font.pixelSize: 16

    // Timer to update the clock every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
        }
    }

    // Set initial text
    Component.onCompleted: {
        clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
    }
}
