
// modules/quickshell/launcher/Launcher.qml
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import "../lib/fuzzysort.js" as FuzzySort
import Qt.labs.fs 1.0

Window {
    id: window
    width: 800
    height: 500
    visible: true
    title: "QuickShell Launcher"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    // Component to write the selected command to a temp file
    FileSystem {
        id: fs
    }

    // The file path for signaling the chosen command to the shell script
    property string commandFile: "/tmp/quickshell-launcher.command"

    // --- Models ---
    // The master list of all applications
    ListModel {
        id: sourceAppModel
        ListElement { name: "Terminal"; icon: "T"; command: "alacritty" }
        ListElement { name: "Browser"; icon: "B"; command: "firefox" }
        ListElement { name: "Files"; icon: "F"; command: "dolphin" }
        ListElement { name: "VS Code"; icon: "C"; command: "code" }
        ListElement { name: "Settings"; icon: "S"; command: "" } // Empty command for disabled items
    }

    // The filtered list that is displayed on screen
    ListModel {
        id: filteredAppModel
    }

    // --- Main UI ---
    Rectangle {
        id: launcherOverlay
        anchors.fill: parent
        color: "#00000080"

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    Rectangle {
        id: launcher
        width: 650
        height: 450
        anchors.centerIn: parent
        color: "#282A36"
        border.color: "#6272A4"
        border.width: 1
        radius: 10

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            SearchBox {
                id: searchBox
                Layout.fillWidth: true
                onTextChanged: filterApps(text)
            }

            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 130
                cellHeight: 120
                model: filteredAppModel
                
                delegate: AppDelegate {
                    appName: model.name
                    appIcon: model.icon
                }

                onItemClicked: (item) => {
                    if (item.model.command) {
                        fs.writeFile(commandFile, item.model.command)
                        Qt.quit()
                    }
                }
            }
        }
    }

    // --- Logic ---
    function filterApps(searchText) {
        filteredAppModel.clear();

        if (searchText.trim() === "") {
            // If search is empty, show all apps
            for (let i = 0; i < sourceAppModel.count; i++) {
                filteredAppModel.append(sourceAppModel.get(i));
            }
            return;
        }

        // Use fuzzysort to find matches
        const results = FuzzySort.go(searchText, sourceAppModel, {key:'name'});

        // Add results to the filtered model
        for (let i = 0; i < results.length; i++) {
            filteredAppModel.append(results[i].obj);
        }
    }

    // --- Lifecycle ---
    Component.onCompleted: {
        // Initially, show all applications
        filterApps("");
        // Focus the search box on startup
        searchBox.input.forceActiveFocus();
    }
}
