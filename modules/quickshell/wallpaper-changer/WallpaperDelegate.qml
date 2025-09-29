import QtQuick

Rectangle {
    id: delegateRoot
    width: 290
    height: 190
    color: "transparent"
    radius: 8

    property string wallpaperPath: ""

    // Extract filename from path for display
    property string wallpaperFile: wallpaperPath.substring(wallpaperPath.lastIndexOf('/') + 1)

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? "#444444" : "transparent"
        border.color: "#888888"
        border.width: 2
        radius: 8
    }

    Image {
        id: thumbnail
        anchors.fill: parent
        anchors.margins: 2
        source: "file://" + wallpaperPath
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        color: Qt.rgba(0, 0, 0, 0.6)
        Text {
            anchors.centerIn: parent
            text: wallpaperFile
            color: "#FFFFFF"
            font.bold: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            // Like the launcher, print the path to stdout and quit.
            console.log("DEBUG qml: " + wallpaperPath)
            Qt.quit()
        }
    }
}
