import QtQuick 2.6

Item {
    id: caveView
    clip: true
    Image {
        id: scrollingBackground
        fillMode: Image.TileHorizontally
        width: sourceSize.width + parent.width // make wider by parent.width to get tiled for the overlap before loop
        height: parent.height
        horizontalAlignment: Image.AlignLeft
        source: "resources/cavescroll.png"
        cache: true
        smooth: false // pixel art
        // Must force animation to reload (via stop/restart) to get correct timing and shift distance
        onWidthChanged: { if (visible) { animation.restart(); } else {animation.stop(); } }
        onVisibleChanged: { if (visible) { animation.restart(); } else { animation.stop(); } }
        NumberAnimation on x {
            id: animation;
            running: visible
            easing.type: Easing.Linear
            loops: Animation.Infinite
            from: 0
            to: -scrollingBackground.sourceSize.width
            duration: 30 * 1000
        }
    }

    SpriteSequence {
        id: cosmo
        smooth: false // pixel art
        height: parent.height * 0.28
        width: height
        x: caveView.width * 0.60
        y: caveView.height * 0.32
        interpolate: true
        running: true
        property int frameDuration: 400
        Sprite{
            name: "1"
            source: "qrc:/resources/player_run1.png"
            frameDuration: cosmo.frameDuration
            to: {"2":1}
        }
        Sprite{
            name: "2"
            source: "qrc:/resources/player_run2.png"
            frameDuration: cosmo.frameDuration
            to: {"3":1}
        }
        Sprite{
            name: "3"
            source: "qrc:/resources/player_run3.png"
            frameDuration: cosmo.frameDuration
            to: {"4":1}
        }
        Sprite{
            name: "4"
            source: "qrc:/resources/player_run4.png"
            frameDuration: cosmo.frameDuration
            to: {"1":1}
        }
    }

    Item {
        id: blastItem
        width: parent.width
        height: parent.height
        visible: true
        property int blastCount: 0

        function addBlast() {
            for (var i = 0; i < blastRepeater.count; i++) {
                if (!blastRepeater.itemAt(i).visible) {
                    blastRepeater.itemAt(i).visible = true
                    break;
                }
            }
        }

        Repeater {
            id: blastRepeater
            model: 10 // max 10 blast pool
            delegate: Item {
                id: blast
                height: parent.height * 0.28
                width: height
                x: (cosmo.x * percent)
                y: caveView.height * 0.34
                property real percent: 0.9
                visible: false // disable at creation
                onVisibleChanged: {
                    if (visible) percent = 0.9;
                    if (visible) { blastItem.blastCount++; } else { blastItem.blastCount--; }
                }

                Timer {
                    interval: 500; running: visible; repeat: true
                    onTriggered: {
                        blast.percent = Math.max(blast.percent - 0.05, 0.0)

                        var percent = -1;
                        var index = -1
                        for (var i = 0; i < repeater.count; i++) {
                            if (repeater.itemAt(i).visible && repeater.itemAt(i).percent > percent) {
                                percent = repeater.itemAt(i).percent
                                index = i;
                            }
                        }
                        if (index >= 0 && repeater.itemAt(index).percent >= blast.percent) {
                            repeater.itemAt(index).visible = false
                            blast.visible = false
                        }
                    }
                }

                SpriteSequence {
                    id: blastSeq
                    width: parent.width
                    height: parent.height
                    smooth: false // pixel art
                    interpolate: true
                    running: visible

                    property int frameDuration: 400
                    Sprite{
                        name: "1"
                        source: "qrc:/resources/blast%1.png".arg(name)
                        frameDuration: blastSeq.frameDuration
                        to: {"2":1}
                    }
                    Sprite{
                        name: "2"
                        source: "qrc:/resources/blast%1.png".arg(name)
                        frameDuration: blastSeq.frameDuration
                        to: {"1":1}
                    }
                }
            }
        }
    }

    property var enemyList: [
        "qrc:/resources/bat.png",
        "qrc:/resources/slime.png",
        "qrc:/resources/dog.png",
    ]

    Item {
        id: enemies
        width: parent.width
        height: parent.height
        property int enemiesCount: 0

        // Add enemies over time, faster as level goes up
        Timer {
            id: enemiesTimer
            interval: Math.floor(Math.random() * Math.max((10 - game.level), 0) + 10) * 1000; running: visible; repeat: true
            onTriggered: {
                for (var i = 0; i < repeater.count; i++) {
                    if (!repeater.itemAt(i).visible) {
                        repeater.itemAt(i).visible = true;
                        repeater.itemAt(i).enemyidx = Math.floor(Math.random() * enemyList.length)
                        repeater.itemAt(i).percent = 0;
                        return;
                    }
                }
            }
        }

        Repeater {
            id: repeater
            model: 10 // max 10 enemies pool
            delegate: Item {
                id: enemy
                height: parent.height * 0.28
                width: height
                x: (cosmo.x * percent)
                y: caveView.height * 0.32
                property real percent: 0
                property int enemyidx: Math.floor(Math.random() * enemyList.length)
                visible: false // disable at creation
                onVisibleChanged: { if (visible) { enemies.enemiesCount++; } else { enemies.enemiesCount--; } }

                Timer {
                    interval: (Math.floor(Math.random() * Math.max((10 - game.level), 0)) + 3) * 1000; running: visible; repeat: true
                    onTriggered: {
                        enemy.percent = Math.min(enemy.percent + 0.05, 1.0)
                        if (enemy.percent >= 1.0) game.gameOver = true;
                    }
                }
                SpriteSequence {
                    id: enemySeq
                    width: parent.width
                    height: parent.height
                    smooth: false // pixel art
                    interpolate: true
                    running: visible

                    property int frameDuration: 400
                    Sprite{
                        name: "1"
                        source: enemyList[enemy.enemyidx].replace(".png", "%1.png").arg(name)
                        frameDuration: enemySeq.frameDuration
                        to: {"2":1}
                    }
                    Sprite{
                        name: "2"
                        source: enemyList[enemy.enemyidx].replace(".png", "%1.png").arg(name)
                        frameDuration: enemySeq.frameDuration
                        to: {"3":1}
                    }
                    Sprite{
                        name: "3"
                        source: enemyList[enemy.enemyidx].replace(".png", "%1.png").arg(name)
                        frameDuration: enemySeq.frameDuration
                        to: {"4":1}
                    }
                    Sprite{
                        name: "4"
                        source: enemyList[enemy.enemyidx].replace(".png", "%1.png").arg(name)
                        frameDuration: enemySeq.frameDuration
                        to: {"1":1}
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: caveView
        text: "GAME OVER"
        horizontalAlignment: Text.horizontalAlignment
        font.pixelSize: parent.width * 0.10
        font.bold: true
        color: "red"
        style: Text.Outline
        styleColor: "black"
        visible: game.gameOver
    }

    Connections {
        target: game
        onScoreChanged: {
            // Only do blaster if there are enemies
            if (enemies.enemiesCount > blastItem.blastCount) blastItem.addBlast()
        }
    }


    Component.onCompleted: {
        // On load, make 1 monster visible
        repeater.itemAt(0).visible = true;
        repeater.itemAt(0).enemyidx = Math.floor(Math.random() * enemyList.length)
        repeater.itemAt(0).percent = 0;
    }
}
