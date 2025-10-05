import QtQuick
import QtQuick.Layouts
import "../theme"
import "widgets"

// Taskbar.qml
// This component is the top bar, which assembles other widgets.

Rectangle {
    id: taskbar
    height: 40
    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.85)
    border.color: Qt.rgba(Colors.color8.r, Colors.color8.g, Colors.color8.b, 0.3)
    border.width: 1

    property int activeWorkspace: 1
    
    // Add subtle shadow effect
    layer.enabled: true
    layer.effect: ShaderEffect {
        property color shadowColor: Qt.rgba(0, 0, 0, 0.3)
    }

    // --- State Loading Function ---
    function loadState() {
        var xhr = new XMLHttpRequest();
        var url = "file:///home/alibek/.cache/rice/active_workspace.txt";
        xhr.open("GET", url, true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) { // status 0 is for local files
                    if (xhr.responseText) {
                        try {
                            var newActive = parseInt(xhr.responseText.trim(), 10);
                            if (taskbar.activeWorkspace !== newActive) {
                                taskbar.activeWorkspace = newActive;
                            }
                        } catch (e) {
                            console.log("!!! QML PARSE ERROR: " + e.toString())
                        }
                    } // else: file is empty, do nothing
                } else {
                    console.log("!!! QML FILE READ ERROR: Status was " + xhr.status)
                }
            }
        }
        xhr.send();
    }

    // --- Timer for Polling ---
    Timer {
        interval: 100 // Poll every 100ms for responsiveness
        running: true
        repeat: true
        onTriggered: { loadState() }
    }

    // --- Main Taskbar UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 15

        // --- Workspace Indicators ---
        RowLayout {
            id: workspaceIndicators
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            // App launcher button (optional)
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: Qt.rgba(Colors.color4.r, Colors.color4.g, Colors.color4.b, 0.3)
                border.color: Colors.color4
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "⚙"
                    font.pixelSize: 16
                    color: Colors.foreground
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    
                    onEntered: parent.color = Qt.rgba(Colors.color4.r, Colors.color4.g, Colors.color4.b, 0.5)
                    onExited: parent.color = Qt.rgba(Colors.color4.r, Colors.color4.g, Colors.color4.b, 0.3)
                    onClicked: {
                        console.log("sh ~/.local/bin/toggle-launcher.sh")
                    }
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 20
                color: Qt.rgba(Colors.color8.r, Colors.color8.g, Colors.color8.b, 0.3)
            }

            Repeater {
                model: 5
                delegate: Rectangle {
                    id: indicator
                    width: 14
                    height: 14
                    radius: 7

                    // Animate scale and color changes
                    Behavior on scale { 
                        NumberAnimation { 
                            duration: 200
                            easing.type: Easing.OutCubic
                        } 
                    }
                    Behavior on color { 
                        ColorAnimation { 
                            duration: 200 
                        } 
                    }
                    Behavior on border.width {
                        NumberAnimation { duration: 200 }
                    }

                    // Properties are bound to the active workspace
                    property bool isActive: taskbar.activeWorkspace === (index + 1)
                    scale: isActive ? 1.3 : 1.0
                    color: isActive ? Colors.color4 : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.2)
                    border.color: isActive ? Colors.foreground : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.4)
                    border.width: isActive ? 2 : 1

                    // Inner glow for active workspace
                    Rectangle {
                        visible: isActive
                        anchors.centerIn: parent
                        width: parent.width * 0.5
                        height: parent.height * 0.5
                        radius: width / 2
                        color: Colors.foreground
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        
                        onEntered: {
                            if (!indicator.isActive) {
                                indicator.scale = 1.15
                            }
                        }
                        onExited: {
                            if (!indicator.isActive) {
                                indicator.scale = 1.0
                            }
                        }
                        onClicked: {
                            // The helper script handles the state change
                            console.log("sh ~/.local/bin/go-to-ws.sh " + (index + 1))
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // --- System Indicators ---
        RowLayout {
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            VolumeWidget {
                textColor: Colors.foreground
            }

            Rectangle {
                width: 1
                height: 20
                color: Qt.rgba(Colors.color8.r, Colors.color8.g, Colors.color8.b, 0.3)
            }

            BatteryWidget {
                textColor: Colors.foreground
            }

            Rectangle {
                width: 1
                height: 20
                color: Qt.rgba(Colors.color8.r, Colors.color8.g, Colors.color8.b, 0.3)
            }

            ClockWidget {
                color: Colors.foreground
            }
        }
    }
}