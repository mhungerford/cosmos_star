import QtQuick 2.6
import QtQuick.Controls 1.2
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    visibility: (Qt.platform.os == "android") ? Window.FullScreen : Window.Windowed
    // Lets keep the game portrait-mode, even on desktops (and mimic 16:9 to stay similar)
    width: (visibility == Window.FullScreen) ? Screen.width : 576
    height: (visibility == Window.FullScreen) ? Screen.height : 1024

    Item {
        id: app
        anchors.fill: parent

        state: "Title" // default state
        states: [
            State {
                name: "Title"
                PropertyChanges { target: title; visible: true }
            },
            State {
                name: "Game"
                PropertyChanges { target: game; visible: true }
            }
        ]

        property int highScore: 0

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

        Rectangle {
            id: title
            anchors.fill: parent
            visible: false
            color: "darkgray"

            Image {
                anchors.top: parent.top
                width: parent.width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/resources/title_top.png"
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -60
                text: "High Score: %1".arg(app.highScore)
            }

            Image {
                anchors.centerIn: parent
                width: parent.width / 4
                fillMode: Image.PreserveAspectFit
                source: "qrc:/resources/play_button.png"
                MouseArea {
                    anchors.fill: parent
                    onClicked: app.state = "Game"
                }
            }

            Image {
                anchors.bottom: parent.bottom
                width: parent.width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/resources/title_bottom.png"
            }
        }

        // Full-screen Loader for the Game logic
        Loader {
            id: game
            anchors.fill: parent
            source: ""
            visible: false
            onVisibleChanged: {
                game.setSource((visible) ? "qrc:/Game.qml" : "")
            }
        }

        // Support gameExit(score) signal from Game to go back to title page
        Connections {
            target: game.item
            onGameExit: {
                if (score > app.highScore) {
                    app.highScore = score;
                    app.saveHighScore();
                }
                app.state = "Title"
            }
        }

        Component.onCompleted: loadHighScore()
    }
}
