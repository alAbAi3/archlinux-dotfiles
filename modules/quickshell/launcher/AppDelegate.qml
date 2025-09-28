
// modules/quickshell/launcher/AppDelegate.qml
import QtQuick

Rectangle {
    id: delegateRoot
    width: 120
    height: 110
    color: "transparent"
    radius: 8

    property string appName: ""
    property string appIcon: ""
    property string appCommand: ""

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? "#44475A" : "transparent"
        radius: 8
    }

    Text {
        id: appIconText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        font.family: "monospace"
        font.pixelSize: 40
        text: appIcon
        color: "#F8F8F2"
    }

    Text {
        id: appNameText
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 15
        text: appName
        color: "#F8F8F2"
        font.bold: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        // The clicked signal will be handled by the GridView's onItemClicked handler
    }
}
