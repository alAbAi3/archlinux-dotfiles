import QtQuick
import QtQuick.Window

Window {
    width: 600
    height: 800
    visible: true
    color: "black"

    property var appModel: []

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        // Using a hardcoded path for this test to eliminate getenv() as a variable
        var url = "file:///home/alibek/.cache/quickshell_apps.json";
        console.log("Attempting to read:", url)

        xhr.onreadystatechange = function() {
            console.log("XHR readyState:", xhr.readyState, "status:", xhr.status)
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if(xhr.status === 200 || xhr.status === 0) { // status 0 is for local files
                    console.log("File read successfully. Response length:", xhr.responseText.length)
                    try {
                        appModel = JSON.parse(xhr.responseText);
                        console.log("JSON parsed. Model size:", appModel.length)
                    } catch (e) {
                        console.log("!!! JSON PARSE ERROR:", e.toString())
                    }
                } else {
                    console.log("!!! FILE READ ERROR: Status is not 200 or 0")
                }
            }
        }
        xhr.open("GET", url, false); // Synchronous
        xhr.send();
    }

    ListView {
        anchors.fill: parent
        model: appModel
        delegate: Text {
            text: modelData.name
            color: "white"
            font.pixelSize: 14
        }
        
        Text {
             anchors.centerIn: parent
             text: "ListView is empty."
             color: "red"
             font.pixelSize: 24
             visible: parent.count === 0
        }
    }
}
