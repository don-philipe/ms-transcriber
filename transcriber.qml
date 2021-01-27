import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import MuseScore 3.0
import FileIO 3.0

MuseScore {
    menuPath: "Plugins.transcriber"
    version: "0.1"
    description: qsTr("transcription helper")
//    requiresScore: true
    pluginType: "dock"
    dockArea: "top"

    id:mainDock
    height: 300;
    onRun: {}

    property bool playing: false

    function seek (amount) {
        audioPlayer.seek(audioPlayer.position + amount)
        progressBar.value = audioPlayer.position / audioPlayer.duration
    }

    FileIO {
        id: audioFile
        onError: console.log(msg + "  Filename = " + audioFile.source)
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose an audio file")
        nameFilters: [ "Audio files (*.wav *.mp3)" ]
        onAccepted: {
            var filename = fileDialog.fileUrl

            if (filename) {
                audioFile.source = filename
                audioPlayer.source = audioFile.source
                buttonPlayPause.enabled = true
                buttonForward.enabled = true
                buttonBack.enabled = true
            }
        }
    }

    Audio {
        id: audioPlayer
        onPlaying: {
            progressBar.value = audioPlayer.position / audioPlayer.duration
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 6

        ProgressBar {
            id: progressBar
            background: Rectangle {
                color: "#aaaaaa"
            }
        }

        Button {
            id : buttonOpenFile
            text: qsTr("Open file")
            onClicked: {
                fileDialog.open();
            }
        }

        Button {
            id: buttonPlayPause
            text: qsTr("Play/Pause")
            enabled: false
            onClicked: {
                if (playing) {
                    audioPlayer.pause()
                } else {
                    audioPlayer.play()
                }
                playing = !playing
            }
        }

        Button {
            id: buttonBack
            text: qsTr("<")
            enabled: false
            onClicked: {
                seek(-5000)
            }
        }

        Button {
            id: buttonForward
            text: qsTr(">")
            enabled: false
            onClicked: {
                seek(5000)
            }
        }

        Button {
            id : buttonQuit
            text: qsTr("Quit")
            onClicked: {
                audioPlayer.stop()
                Qt.quit();
            }
        }
    }
}
