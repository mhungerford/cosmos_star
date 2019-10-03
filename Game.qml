import QtQuick 2.5
import QtQuick.Layouts 1.3

Rectangle {
    id: game
    signal gameExit(int score)

    property int score: 0
    property int level: score / 10 + 1
    property bool gameOver: false
    onGameOverChanged: {
        if (gameOver) gameOverTimer.restart();
    }
    Timer {
        id: gameOverTimer
        interval: (5000); running: false; repeat: false
        onTriggered: gameExit(score)
    }

    anchors.fill: parent
    color: "darkslategray"

    property var tiles: [
        "qrc:/resources/red_tile.png",
        "qrc:/resources/green_tile.png",
        "qrc:/resources/blue_tile.png",
        "qrc:/resources/white_tile.png",
    ]

    // Need at least 24 tiles, so 12 matching icons
    property var icons: [
        "qrc:/resources/blue_monster.png",
        "qrc:/resources/brown_monster.png",
        "qrc:/resources/green_monster.png",
        "qrc:/resources/orange_monster.png",
        "qrc:/resources/pink_monster.png",
        "qrc:/resources/purple_monster.png",
        "qrc:/resources/red_monster.png",
        "qrc:/resources/yellow_monster.png",

        // Game was too difficult, so removed these to create more duplicates
        //"qrc:/resources/darkblue_monster.png",
        //"qrc:/resources/darkgreen_monster.png",
        //"qrc:/resources/lavender_monster.png",
        //"qrc:/resources/magenta_monster.png",
    ]

    CaveView {
        id: caveView
        width: parent.width
        height: parent.height * 0.15
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        anchors.top: caveView.bottom
        anchors.topMargin: parent.height * 0.01
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: parent.width / 20
        font.bold: true
        font.underline: true
        lineHeight: 1.5
        text: "Score: %1".arg(score) + '\n' + "Level: %1".arg(level)
    }

    // Clipping rect to hide top row of tiles, allows for drop animation from above
    Item {
        clip: true
        width: game.width
        height: grid.tilesize * grid.rows - grid.tilesize
        anchors.bottom: game.bottom
        anchors.horizontalCenter: game.horizontalCenter

        Item {
            id: grid
            width: parent.width
            height: tilesize * grid.rows
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            property int rows: 6
            property int columns: 4
            property real tilesize: width / grid.columns // for now, always assume portrait mode
            property var previousItem: null

            Timer {
                id: match3Timer
                interval: (1500); running: false; repeat: false
                onRunningChanged: { grid.enabled = !running; }
                onTriggered: match3()
            }

            Repeater {
                id: repeater
                model: 0
                delegate: Flipable {
                    id: flipable
                    x: col * parent.tilesize
                    y: row * parent.tilesize
                    width: parent.tilesize
                    height: parent.tilesize
                    property string icon: ""
                    property int tileidx: -1
                    property int row: -1
                    property int col: -1

                    property bool flipped: false
                    property real angle: flipped ? 180 : 0
                    property string source: icon
                    property int flipDuration: 1000
                    property bool active: true;

                    transform: Rotation {id : rotationTile; angle : flipable.angle; axis {x : 0; y: 1; z : 0} origin.x : width * 0.5; origin.y : height * 0.5}
                    Behavior on angle { enabled: flipable.active; NumberAnimation { duration: flipDuration } }
                    Behavior on y { enabled: flipable.active; NumberAnimation { duration: 600; } }

                    Timer {
                        id: unflipTimer
                        interval: (1 * 1000); running: false; repeat: false
                        onRunningChanged: { grid.enabled = !running; }
                        onTriggered: {
                            flipable.flipped = false;
                            if (grid.previousItem !== null) {
                                grid.previousItem.flipped = false;
                            }
                            grid.previousItem = null;
                        }
                    }

                    function startPairTimer() {
                        pairTimer.restart();
                    }

                    Timer {
                        id: pairTimer
                        interval: (1500); running: false; repeat: false
                        onRunningChanged: { grid.enabled = !running; }
                        onTriggered: removeTileByIndex(index)
                    }


                    Timer {
                        id: resetTimer
                        interval: (5 * 1000); running: false; repeat: false
                        onTriggered: game.gameExit(score)
                    }

                    front: Image {
                        source: (tileidx >= 0) ? tiles[tileidx] : ""
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        smooth : false
                    }
                    back: Image {
                        source: flipable.icon
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        smooth : true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!unflipTimer.running && !flipable.flipped) {
                                flipable.flipped = true;

                                if (grid.previousItem !== null) {
                                    if (icon === grid.previousItem.source) {
                                        // Matched previously flipped tile
                                        startPairTimer();
                                        grid.previousItem.startPairTimer();
                                        grid.previousItem = null;
                                    } else {
                                        unflipTimer.restart()
                                    }
                                } else {
                                    grid.previousItem = flipable
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function addRandomTile(col) {
        for (var i = 0; i < repeater.count; i++) {
            var itile = repeater.itemAt(i);
            if (itile.row == -1 && itile.col == -1) {
                itile.active = true;
                itile.row = 0;
                itile.col = col;
                itile.tileidx = Math.floor(Math.random() * tiles.length)
                break;
            }
        }
    }

    function removeTileByIndex(index) {
        var itile = repeater.itemAt(index);
        var col = itile.col
        for (var i = 0; i < repeater.count; i++) {
            if (repeater.itemAt(i).col === itile.col) {
                if (repeater.itemAt(i).row < itile.row) {
                    repeater.itemAt(i).row++;
                }
            }
        }
        itile.active = false;
        itile.row = -1;
        itile.col = -1;
        itile.flipped = false;
        addRandomTile(col)
        match3Timer.restart();
    }

    function removeColorByRow(row, color) {
        for (var i = 0; i < repeater.count; i++) {
            var itile = repeater.itemAt(i);
            if (itile.row === row && itile.tileidx === color) {
                removeTileByIndex(i);
            }
        }
    }

    function removeColorByCol(col, color) {
        for (var i = 0; i < repeater.count; i++) {
            var itile = repeater.itemAt(i);
            if (itile.col === col && itile.tileidx === color) {
                removeTileByIndex(i);
            }
        }
    }

    function match3() {
        var rowColors = new Array(grid.rows);
        for (var i = 0; i < grid.rows; i++) {
            rowColors[i] = new Array(tiles.length);
        }

        var colColors = new Array(grid.columns);
        for (var i = 0; i < grid.columns; i++) {
            colColors[i] = new Array(tiles.length);
        }

        for (var i = 0; i < repeater.count; i++) {
            var itile = repeater.itemAt(i);
            if (itile.row >= 1 && itile.col !== -1) {
                rowColors[itile.row][itile.tileidx] = rowColors[itile.row][itile.tileidx] | (0x1 << itile.col);
                colColors[itile.col][itile.tileidx] = colColors[itile.col][itile.tileidx] | (0x1 << itile.row);
            }
        }

        for (var r = 0; r < grid.rows; r++) {
            for (var c = 0; c < tiles.length; c++) {
                var count = 0;
                var temp = rowColors[r][c];
                while (temp > 0) {
                    temp &= (temp << 1);
                    count += 1;
                }
                if (count >= 3) {
                    removeColorByRow(r, c);
                    score++;
                }
            }
        }

        for (var col = 0; col < grid.columns; col++) {
            for (var c = 0; c < tiles.length; c++) {
                var count = 0;
                var temp = colColors[col][c];
                while (temp > 0) {
                    temp &= (temp << 1);
                    count += 1;
                }
                if (count >= 3) {
                    // Bug, removes even non-consecutive of the same color
                    removeColorByCol(col, c);
                    score++;
                }
            }
        }
    }

    function shuffleDeck() {
        function shuffleArray(array) {
            for (var i = array.length - 1; i > 0; i--) {
                var j = Math.floor(Math.random() * (i + 1));
                var temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }
        }

        var deck = []
        for (var i = 0; i < icons.length; i++) {
            deck.push(i);
            deck.push(i);
            deck.push(i);
        }
        shuffleArray(deck)

        repeater.model = deck.length

        for (var i=0; i < deck.length; i++) {
            repeater.itemAt(i).tileidx = Math.floor(Math.random() * tiles.length)
            repeater.itemAt(i).icon = icons[deck[i]];
            repeater.itemAt(i).flipped = false
            repeater.itemAt(i).col = i % 4
            repeater.itemAt(i).row = Math.floor(i / 4)
        }

    }

    Component.onCompleted: {
        shuffleDeck()
    }
}
