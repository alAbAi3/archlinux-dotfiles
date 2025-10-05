import QtQuick

// SimpleSystemWidget.qml
// A simple widget that shows basic system info without crashing

Row {
    id: systemWidget
    spacing: 15
    
    property color textColor: "white"
    
    // Simple volume indicator (placeholder - will update via script)
    Text {
        text: "🔊"
        font.pixelSize: 14
        color: textColor
    }
    
    // Simple battery indicator (placeholder - will update via script)
    Text {
        text: "🔋"
        font.pixelSize: 14
        color: textColor
    }
}
