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

    // Update progress bar with current audio player position.
    function updateProgress () {
        progressBar.value = audioPlayer.position / audioPlayer.duration
    }

    // Seek forward or backward in the current audio track by the given positiv or negative
    // amount of milliseconds.
    function seek (amount) {
        audioPlayer.seek(audioPlayer.position + amount)
        updateProgress()
    }

// use for file readability check?
//    FileIO {
//        id: audioFile
//        onError: console.log(msg + "  Filename = " + audioFile.source)
//    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose an audio file")
        nameFilters: [ "Audio files (*.wav *.mp3 *.m4a *.ogg)" ]
        onAccepted: {
            var filename = fileDialog.fileUrl

            if (filename) {
                audioPlayer.source = filename
                buttonPlayPause.enabled = true
                buttonForward.enabled = true
                buttonBack.enabled = true
            }
        }
    }

    Timer {
        id: playingTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            updateProgress()
        }
    }

    Audio {
        id: audioPlayer
        onPlaying: {
            playingTimer.start()
        }
        onStopped: {
            playingTimer.stop()
        }
        onPaused: {
            playingTimer.stop()
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 5
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        ProgressBar {
            id: progressBar
            Layout.columnSpan: 5
            Layout.fillWidth: true
            background: Rectangle {
                color: "#aaaaaa"
            }
        }

        Button {
            id : buttonOpenFile
            text: qsTr("Open file")
            onClicked: {
                audioPlayer.stop()
                updateProgress()
                fileDialog.open()
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
                Qt.quit()
            }
        }
    }
}
