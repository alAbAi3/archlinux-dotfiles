import QtQuick
import QtQuick.Layouts

// VolumeWidget.qml
// Displays volume status with icon

RowLayout {
    id: volumeWidget
    spacing: 6
    
    property color textColor: "white"
    property int volumeLevel: 100
    property bool isMuted: false
    
    // Update volume status periodically
    Timer {
        interval: 2000 // Check every 2 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateVolumeStatus()
    }
    
    function updateVolumeStatus() {
        // Use pactl to get volume info
        // This requires running an external command, so we write to a temp file
        // Note: This is a placeholder - you'll need a helper script for this
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/rice_volume.txt", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 0)) {
                var data = xhr.responseText.trim().split(':');
                if (data.length === 2) {
                    volumeLevel = parseInt(data[0], 10);
                    isMuted = data[1] === "1";
                }
            }
        }
        xhr.send();
    }
    
    // Volume icon
    Text {
        text: isMuted ? "🔇" : (volumeLevel > 50 ? "🔊" : (volumeLevel > 0 ? "🔉" : "🔈"))
        font.pixelSize: 14
        color: textColor
    }
    
    Text {
        text: isMuted ? "M" : volumeLevel + "%"
        font.pixelSize: 12
        font.family: "monospace"
        color: textColor
    }
}
