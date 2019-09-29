import QtQuick 2.6
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    visibility: (Qt.platform.os == "android") ? Window.FullScreen : Window.Windowed
    width: (visibility == Window.FullScreen) ? Screen.width : 1024
    height: (visibility == Window.FullScreen) ? Screen.height : 768

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
                onClicked: gameLoader.setSource("qrc:/Game.qml")
            }
        }
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        visible: true;//active
    }

    Component.onCompleted: { }
    Connections {
        target: gameLoader.item
        onGameExit: { gameLoader.setSource(""); console.log("onGameExit"); }
    }
}
