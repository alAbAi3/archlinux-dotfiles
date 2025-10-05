// modules/quickshell/launcher/SearchBox.qml
import QtQuick
import theme

Rectangle {
    id: searchBox
    height: 55
    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.5)
    radius: 10
    border.color: searchInput.activeFocus ? Colors.color4 : Qt.rgba(Colors.color5.r, Colors.color5.g, Colors.color5.b, 0.3)
    border.width: searchInput.activeFocus ? 2 : 1

    property alias text: searchInput.text
    property alias input: searchInput

    // Define signals that this component can emit
    signal accepted()
    
    Behavior on border.color { ColorAnimation { duration: 200 } }
    Behavior on border.width { NumberAnimation { duration: 200 } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 10
        
        // Search icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "🔍"
            font.pixelSize: 18
            opacity: 0.7
        }
        
        TextInput {
            id: searchInput
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40
            
            color: Colors.foreground
            font.pixelSize: 18
            
            selectByMouse: true
            selectionColor: Colors.color4

            // When the underlying TextInput is accepted (Enter pressed), emit our own signal
            onAccepted: searchBox.accepted()
            
            // The placeholder text
            Text {
                text: "Search apps..."
                color: Qt.rgba(Colors.color8.r, Colors.color8.g, Colors.color8.b, 0.5)
                font.pixelSize: 18
                visible: !searchInput.text
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Clear button
        Rectangle {
            visible: searchInput.text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            radius: 12
            color: clearMouseArea.containsMouse ? Qt.rgba(Colors.color1.r, Colors.color1.g, Colors.color1.b, 0.5) : "transparent"
            
            Behavior on color { ColorAnimation { duration: 150 } }
            
            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 14
                color: Colors.foreground
                opacity: 0.7
            }
            
            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: searchInput.text = ""
            }
        }
    }
}