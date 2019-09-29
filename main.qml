import QtQuick 2.6
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Image {
        anchors.centerIn: parent
        width: parent.width / 4
        fillMode: Image.PreserveAspectFit
        source: "qrc:/resources/play_button.png"
        MouseArea {
            anchors.fill: parent
            onClicked: console.log("Play clicked")
        }
    }

}

