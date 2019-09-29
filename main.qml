import QtQuick 2.6
import QtQuick.Controls 1.2
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    visibility: (Qt.platform.os == "android") ? Window.FullScreen : Window.Windowed
    width: (visibility == Window.FullScreen) ? Screen.width : 1024
    height: (visibility == Window.FullScreen) ? Screen.height : 768

    property int highScore: 0

    Rectangle {
        anchors.fill: parent
        color: "darkgray"

        Image {
            anchors.centerIn: parent
            width: parent.width / 4
            fillMode: Image.PreserveAspectFit
            source: "qrc:/resources/play_button.png"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    highScore = highScore + 10
                    saveHighScore();
                    gameLoader.setSource("qrc:/Game.qml")
                }
            }
        }
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        visible: true;//active
    }

    function loadHighScore() {
        console.log("loadHighScore");
        var db = LocalStorage.openDatabaseSync("HighScore", "1.0", "Cosmo's Star High Score", 100);
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS HighScore(score NUMBER)');
            var rs = tx.executeSql('SELECT * FROM HighScore')
            // Load the highScore, should only be 1 entry
            for (var i = 0; i < rs.rows.length; i++) {
                highScore = rs.rows.item(i).score;
                console.log("Loaded HighScore: " + highScore);
            }
        });
    }

    function saveHighScore() {
        console.log("saveHighScore");
        var db = LocalStorage.openDatabaseSync("HighScore", "1.0", "Cosmo's Star High Score", 100);
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM HighScore'); // Clear the previous highScore
            tx.executeSql('INSERT INTO HighScore VALUES(?)', [highScore]); // Save the new highScore
        });
    }

    Connections {
        target: gameLoader.item
        onGameExit: { gameLoader.setSource(""); console.log("onGameExit"); }
    }

    Component.onCompleted: { loadHighScore(); }

}
