import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import MuseScore 3.0
import FileIO 3.0

//TODO change playback speed: load audio data into additional property and do pitch correction via JS

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
    property variant totalDurationSec: qsTr("0:00")
    property variant trackTitle: qsTr("NA")

    function millisToMinSec (milliseconds) {
        let seconds = milliseconds / 1000
        let i = 0
        while (seconds > 59) {
            seconds = seconds - 60
            i++
        }
        seconds = seconds.toFixed()

        let zero = qsTr("")
        if (seconds < 10) {
            zero = qsTr("0")
        }

        return qsTr(i + ":" + zero + seconds)
    }

    // Update progress bar with current audio player position.
    function updateProgress () {
        progressBar.value = audioPlayer.position / audioPlayer.duration
        progressText.text = qsTr(millisToMinSec(audioPlayer.position) + " / " + totalDurationSec)
    }

    // Seek forward or backward in the current audio track by the given positiv or negative
    // amount of milliseconds.
    function seek (amount) {
        audioPlayer.seek(audioPlayer.position + amount)
        updateProgress()
    }

    // Go to relative position in current track. Used by click on progress bar. The relative position
    // must be a value between 0.0 and 1.0
    function goToTrackPos (relPos) {
        audioPlayer.seek(audioPlayer.duration * relPos)
        updateProgress()
    }

    // Prepare for audio playing. Update total duration, checks for track title etc.
    function processAudio () {
        totalDurationSec = millisToMinSec(audioPlayer.duration)

        if (audioPlayer.metaData.title !== undefined) {
            trackTitle = qsTr(audioPlayer.metaData.title)
        } else {
            trackTitle = qsTr(audioPlayer.source.toString())
        }

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
                bufferTimer.start()
            }
        }
    }

    // For polling the audio buffer state so that finally processAudio() can be called.
    Timer {
        id: bufferTimer
        interval: 20
        running: false
        repeat: false
        onTriggered: {
            if (audioPlayer.bufferProgress == 1) {
                processAudio()
            } else {
                bufferTimer.restart()
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
        height: 25

        Text {
            id: trackTitleText
            Layout.columnSpan: 5
            text: qsTr(trackTitle)
        }

        ProgressBar {
            id: progressBar
            Layout.columnSpan: 4
            Layout.fillWidth: true
            background: Rectangle {
                color: "#aaaaaa"
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: {
                    var pos = mapToItem(progressBar, mouse.x, mouse.y)
                    var relPos = pos.x / progressBar.width
                    goToTrackPos(relPos)
                }
            }
        }

        Text {
            id: progressText
            text: qsTr("NA / NA")
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
