import QtQuick 2.6
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

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

            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: titleTextImage.sourceSize.height

                Image {
                    id: titleTextImage
                    width: parent.width
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/resources/title_center.png"
                }

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width / 2
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/resources/play_button.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: app.state = "Game"
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: parent.width / 20
                    font.bold: true
                    font.underline: true
                    text: "High Score: %1".arg(app.highScore)
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

        Item {
            // Wrap LocalStorage to avoid it on WebAssembly builds
            // Load/Save the highScore, should only be 1 entry
            id: localStorageWrapper
            property bool localStorageAvailable: (Qt.platform.os !== "unix")
            function loadHighScore() {
                if (localStorageAvailable) localStorageObject.loadHighScore();
                return (localStorageAvailable) ? localStorageObject.score : 0;
            }
            function saveHighScore(score) { if (localStorageAvailable) localStorageObject.saveHighScore(score); }
            // Odd workaround, returning is always undefined, but storing property and reading it works
            property var localStorageObject: !localStorageAvailable ? {} : Qt.createQmlObject(
                'import QtQuick 2.6;' +
                'import QtQuick.LocalStorage 2.0;' +
                'Item {' +
                    'property int score: 0;' +
                    'function loadHighScore() {' +
                        'var db = LocalStorage.openDatabaseSync("HighScore", "1.0", "Cosmo\'s Star High Score", 100);' +
                        'db.transaction(function(tx) {' +
                            'tx.executeSql(\'CREATE TABLE IF NOT EXISTS HighScore(score NUMBER)\');' +
                            'var rs = tx.executeSql(\'SELECT * FROM HighScore\');' +
                            'for (var i = 0; i < rs.rows.length; i++) {' +
                                'score = rs.rows.item(i).score;' +
                            '}' +
                        '});' +
                    '}\n' +
                    'function saveHighScore(score) {' +
                        'var db = LocalStorage.openDatabaseSync("HighScore", "1.0", "Cosmo\'s Star High Score", 100);' +
                        'db.transaction(function(tx) {' +
                            'tx.executeSql(\'DELETE FROM HighScore\');' +
                            'tx.executeSql(\'INSERT INTO HighScore VALUES(?)\', [score]);' +
                        '});' +
                    '}' +
                '}', parent)
        }

        // Support gameExit(score) signal from Game to go back to title page
        Connections {
            target: game.item
            onGameExit: {
                if (score > app.highScore) {
                    app.highScore = score;
                    localStorageWrapper.saveHighScore(app.highScore);
                }
                app.state = "Title"
            }
        }

        Component.onCompleted: { app.highScore = localStorageWrapper.loadHighScore(); }
    }
}
