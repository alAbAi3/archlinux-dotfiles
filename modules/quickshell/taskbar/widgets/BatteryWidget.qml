import QtQuick
import QtQuick.Layouts

// BatteryWidget.qml
// Displays battery status with icon and percentage

RowLayout {
    id: batteryWidget
    spacing: 6
    
    property color textColor: "white"
    property int batteryLevel: 100
    property bool isCharging: false
    
    // Update battery status periodically
    Timer {
        interval: 10000 // Check every 10 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateBatteryStatus()
    }
    
    function updateBatteryStatus() {
        // Read battery status from /sys/class/power_supply/BAT0/
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///sys/class/power_supply/BAT0/capacity", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 0)) {
                batteryLevel = parseInt(xhr.responseText.trim(), 10);
            }
        }
        xhr.send();
        
        var xhr2 = new XMLHttpRequest();
        xhr2.open("GET", "file:///sys/class/power_supply/BAT0/status", true);
        xhr2.onreadystatechange = function() {
            if (xhr2.readyState === XMLHttpRequest.DONE && (xhr2.status === 200 || xhr2.status === 0)) {
                isCharging = xhr2.responseText.trim() === "Charging";
            }
        }
        xhr2.send();
    }
    
    // Battery icon (simple representation)
    Rectangle {
        width: 24
        height: 12
        radius: 2
        color: "transparent"
        border.color: textColor
        border.width: 1.5
        
        // Battery level fill
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: Math.max(0, (parent.width - 4) * batteryLevel / 100)
            radius: 1
            color: batteryLevel > 20 ? textColor : "#ff5555"
            
            Behavior on width { NumberAnimation { duration: 300 } }
            Behavior on color { ColorAnimation { duration: 300 } }
        }
        
        // Battery terminal
        Rectangle {
            anchors.left: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 6
            color: textColor
        }
        
        // Charging indicator
        Text {
            visible: isCharging
            anchors.centerIn: parent
            text: "⚡"
            font.pixelSize: 10
            color: textColor
        }
    }
    
    Text {
        text: batteryLevel + "%"
        font.pixelSize: 12
        font.family: "monospace"
        color: textColor
    }
}
