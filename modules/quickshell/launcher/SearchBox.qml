// modules/quickshell/launcher/SearchBox.qml
import QtQuick
import theme

Rectangle {
    id: searchBox
    height: 55
    color: Colors.color0
    radius: 10
    border.color: Colors.color5
    border.width: 1

    property alias text: searchInput.text
    property alias input: searchInput

    // Define signals that this component can emit
    signal accepted()
    signal textChanged(string text)

    TextInput {
        id: searchInput
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        
        color: Colors.foreground
        font.pixelSize: 20
        
        verticalAlignment: TextInput.AlignVCenter

        // When the underlying TextInput is accepted (Enter pressed), emit our own signal
        onAccepted: searchBox.accepted()
        onTextChanged: searchBox.textChanged(text)
        
        // The placeholder text
        Text {
            text: "Search apps..."
            color: Colors.color8
            font.pixelSize: 20
            visible: !searchInput.text
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
        }
    }
}