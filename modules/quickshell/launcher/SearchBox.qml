
// modules/quickshell/launcher/SearchBox.qml
import QtQuick
import "../theme"

Rectangle {
    id: searchBox
    height: 50
    color: Colors.color0
    radius: 8
    border.color: Colors.color5
    border.width: 1

    property alias text: searchInput.text
    property alias input: searchInput

    // Define a signal that this component can emit
    signal accepted()

    TextInput {
        id: searchInput
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        
        color: Colors.foreground
        font.pixelSize: 18
        
        verticalAlignment: TextInput.AlignVCenter

        // When the underlying TextInput is accepted (Enter pressed), emit our own signal
        onAccepted: searchBox.accepted()
        
        // The placeholder text
        Text {
            text: "Search apps..."
            color: Colors.color8
            font.pixelSize: 18
            visible: !searchInput.text
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
        }
    }
}
