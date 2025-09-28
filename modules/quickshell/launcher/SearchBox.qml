
// modules/quickshell/launcher/SearchBox.qml
import QtQuick

Rectangle {
    id: searchBox
    height: 50
    color: "#383A4A"
    radius: 8
    border.color: "#BD93F9"
    border.width: 1

    property alias text: searchInput.text
    property alias input: searchInput

    TextInput {
        id: searchInput
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        
        color: "#F8F8F2"
        font.pixelSize: 18
        
        verticalAlignment: TextInput.AlignVCenter
        
        // The placeholder text
        Text {
            text: "Search apps..."
            color: "#6272A4"
            font.pixelSize: 18
            visible: !searchInput.text
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
        }
    }
}
