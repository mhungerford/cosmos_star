import QtQuick 2.5
import QtQuick.Layouts 1.3

Rectangle {
    id: game
    signal gameExit(int score)

    property int score: 0

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

        // Game was too difficult, so allow more duplicates
        //"qrc:/resources/darkblue_monster.png",
        //"qrc:/resources/darkgreen_monster.png",
        //"qrc:/resources/lavender_monster.png",
        //"qrc:/resources/magenta_monster.png",
    ]

    // Clipping rect to hide top row of tiles, allows for drop animation from above
    Item {
        clip: true
        width: game.width
        height: grid.tilesize * grid.rows - grid.tilesize
        anchors.bottom: game.bottom
        anchors.horizontalCenter: game.horizontalCenter

        GridLayout {
            id: grid
            width: parent.width
            height: tilesize * grid.rows
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            rows: 6
            columns: 4
            columnSpacing: 0
            rowSpacing: 0
            property real tilesize: width / grid.columns // for now, always assume portrait mode
            property var previousItem: null
            property int iconsDone: 0

            Repeater {
                id: repeater
                model: 0
                delegate: Flipable {
                    id: flipable
                    property string icon: ""
                    property string tile: ""
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property bool flipped: false
                    property real angle: flipped ? 180 : 0
                    property bool done: false
                    property string source: icon
                    property int flipDuration: (done) ? 0 : 1000

                    transform: Rotation {id : rotationTile; angle : flipable.angle; axis {x : 0; y: 1; z : 0} origin.x : width * 0.5; origin.y : height * 0.5}
                    Behavior on angle { NumberAnimation { duration: flipDuration } }
                    Behavior on y { NumberAnimation { duration: 1000; } }

                    Timer {
                        id: unflipTimer
                        interval: (1 * 1000); running: false; repeat: false
                        onTriggered: {
                            flipable.flipped = false;
                            if (grid.previousItem !== null) {
                                grid.previousItem.flipped = false;
                            }
                            grid.previousItem = null;
                        }
                    }

                    Timer {
                        id: resetTimer
                        interval: (5 * 1000); running: false; repeat: false
                        onTriggered: game.gameExit(score)
                    }

                    front: Image {
                        source: flipable.tile
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
                            if (!unflipTimer.running && !flipable.done && !flipable.flipped) {
                                flipable.flipped = true;

                                if (grid.previousItem !== null) {
                                    if (icon === grid.previousItem.source) {
                                        // Matched previously flipped tile
                                        flipable.done = true
                                        grid.previousItem.done = true;
                                        grid.previousItem = null;
                                        grid.iconsDone += 2
                                        if (grid.iconsDone == icons.length) {
                                            resetTimer.start()
                                        }
                                    } else {
                                        unflipTimer.start()
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

    function removeTile() {

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
            repeater.itemAt(i).tile = tiles[Math.floor(Math.random() * tiles.length)]
            repeater.itemAt(i).icon = icons[deck[i]];
            repeater.itemAt(i).flipped = false
            repeater.itemAt(i).done = false
        }

    }

    Component.onCompleted: {
        shuffleDeck()
    }
}
