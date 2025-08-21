/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   player
* @brief         PlayerLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-03-08
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import com.alientek.qmlcomponents 1.0
import QtQuick.Layouts 1.12
Item {
    signal mediaDuratrionChaged()
    signal mediaPositonChaged()
    signal sliderPressChaged(bool pressed)
    property bool progress_pressed: false
    property bool tiltleHeightShow: true
    property bool tiltleWidthShow: true
    id: playerLayout
    property real scaleFfactor: window.width / 720
    anchors.fill: parent

    AMediaList {
        id: mediaModel
        currentIndex: -1
        onCurrentIndexChanged: {
        }
    }

    Component.onCompleted: {
        mediaModel.add(appCurrtentDir +  "/resource/media/movies")
    }

    Timer {
        id: playStarttimer
        function setTimeout(cb, delayTime) {
            playStarttimer.interval = delayTime;
            playStarttimer.repeat = false
            playStarttimer.triggered.connect(cb);
            playStarttimer.triggered.connect(function release () {
                playStarttimer.triggered.disconnect(cb)
                playStarttimer.triggered.disconnect(release)
            })
            playStarttimer.start()
        }
    }

    Timer {
        id: timerCountToHide
        interval: 5000
        repeat: false
        onTriggered: {
        }
    }

    MouseArea {
        id: mouseAreaPlayerItem
        anchors.fill: parent
        onClicked: {
            if (timerCountToHide.running)
                timerCountToHide.stop()
            else
                timerCountToHide.restart()
        }
    }

    APlayer {
        id: mediaPlayer
        source: mediaModel.currentMedia
        volume: 1.0
        onSourceChanged: {
        }
        onPositionChanged: {
            if (!progress_pressed)
                playerLayout.mediaPositonChaged()
        }

        onDurationChanged: {
            playerLayout.mediaDuratrionChaged()
        }

        onStateChanged: function() {
            switch (mediaPlayer.state) { 
            case APlayer.PlayingState:
                timerCountToHide.interval = 15000
                timerCountToHide.start()
                break;
            case APlayer.PausedState:
                timerCountToHide.interval = 50000000
                timerCountToHide.restart()
                break;
            case APlayer.StoppedState:
                timerCountToHide.interval = 50000000
                timerCountToHide.restart()
                if (loop_button.checked)
                    mediaPlayer.play()
                break;
            default:
                break;
            }
        }
    }

    function currentMediaTime(time){
        var sec = Math.floor(time / 1000);
        var hours = Math.floor(sec / 3600);
        var minutes = Math.floor((sec - hours * 3600) / 60);
        var seconds = sec - hours * 3600 - minutes * 60;
        var hh, mm, ss;
        if(hours.toString().length < 2)
            hh = "0" + hours.toString();
        else
            hh = hours.toString();
        if(minutes.toString().length < 2)
            mm="0" + minutes.toString();
        else
            mm = minutes.toString();
        if(seconds.toString().length < 2)
            ss = "0" + seconds.toString();
        else
            ss = seconds.toString();
        return hh+":" + mm + ":" + ss
    }

    MediaListView {
        id: mediaListView
        width: parent.width / 3
        height: parent.height
        x: parent.width - width
        Behavior on x { PropertyAnimation { duration: 200; easing.type: Easing.Linear } }
        Button {
            id: playListBt
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 60 * scaleFfactor
            height: width
            checkable: true
            checked: false
            opacity: playListBt.pressed ? 1.0 : 0.8
            anchors.leftMargin: -25 * scaleFfactor
            background: Rectangle {
                anchors.centerIn: parent
                width: 10 * scaleFfactor
                height: 60 * scaleFfactor
                radius: width / 2
                color: "gray"
            }
            onCheckedChanged: {
                if (playListBt.checked)
                    mediaListView.x = playerLayout.width - 10 * scaleFfactor
                else
                    mediaListView.x = playerLayout.width - mediaListView.width
            }
        }
    }

    Item {
        anchors.fill: parent
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            id: bottomPanel
            onVisibleChanged: {
                // if (!visible)
                // volume_dialog.close()
            }
            visible: timerCountToHide.running || mediaPlayer.state === APlayer.StoppedState
            height: rowLayout.height/ 2
            gradient: Gradient {
                GradientStop { position: 1.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#101010" }
                GradientStop { position: 0.0; color: "black" }
            }
            Text{
                id: filmNameText
                width: parent.width
                anchors.centerIn: parent
                text: mediaModel.currentIndex !== -1 ? mediaModel.getcurrentTitle() : ""
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: scaleFfactor * 25
                font.bold: false
                elide: Text.ElideRight
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            visible: timerCountToHide.running || mediaPlayer.state === APlayer.StoppedState
            height: 80 * scaleFfactor
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#101010" }
                GradientStop { position: 1.0; color: "black" }
            }

            RowLayout {
                id: rowLayout
                anchors.fill: parent
                spacing: 5 * scaleFfactor
                Button {
                    id: play_button
                    Layout.preferredWidth: scaleFfactor * 64
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    hoverEnabled: true
                    checkable: true
                    checked: false
                    opacity: play_button.pressed ? 0.5 : 1.0
                    background: Image {
                        id: play_image
                        width: scaleFfactor * 40
                        height: width
                        anchors.centerIn: play_button
                        //opacity: play_button.hovered && !play_button.pressed ? 0.5 : 1.0
                        source: mediaPlayer.state === APlayer.PlayingState ?  "qrc:/icons/videoplayer_pause_icon.png" : "qrc:/icons/videoplayer_play_icon.png"
                    }
                    onClicked: {
                        if(mediaPlayer.state === APlayer.PlayingState)
                            mediaPlayer.pause()
                        else {
                            mediaPlayer.play()
                        }
                    }
                }

                Button {
                    id: next_button
                    Layout.preferredWidth: scaleFfactor * 64
                    Layout.preferredHeight: width
                    hoverEnabled: true
                    visible: true
                    Layout.alignment: Qt.AlignVCenter
                    opacity: next_button.pressed ? 0.5 : 1.0
                    background: Image {
                        id: screen_image
                        width: scaleFfactor * 40
                        height: width
                        anchors.centerIn: next_button
                        source:  "qrc:/icons/videoplayer_next_icon.png"
                    }
                    onClicked: {
                        mediaModel.currentIndex++
                        mediaPlayer.play()
                        timerCountToHide.restart()
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignVCenter
                    id: loop_button
                    Layout.preferredWidth: scaleFfactor * 64
                    Layout.preferredHeight: width / 2
                    hoverEnabled: true
                    checkable: true
                    checked: false
                    opacity: loop_button.checked || loop_button.pressed ? 1.0 : 0.5
                    background: Image {
                        id: loop_image
                        width: scaleFfactor * 40
                        height: width
                        opacity: 1
                        anchors.centerIn: loop_button
                        source: "qrc:/icons/videoplayer_loop_icon.png"
                    }
                }

                Text{
                    id: playTimePosition
                    Layout.alignment: Qt.AlignVCenter
                    text: currentMediaTime(mediaPlayer.position)
                    color: "white"
                    font.pixelSize: scaleFfactor * 15
                    font.bold: true
                }

                PlaySilder {
                    id: silder
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Text{
                    id: playTimeDuration
                    Layout.alignment: Qt.AlignVCenter
                    text: currentMediaTime(mediaPlayer.duration)
                    color: "white"
                    font.pixelSize: scaleFfactor * 15
                    font.bold: true
                }

                Button {
                    id: volume_button
                    Layout.preferredWidth: scaleFfactor * 64
                    Layout.preferredHeight: width / 2
                    hoverEnabled: true
                    checkable: true
                    Layout.alignment: Qt.AlignVCenter
                    opacity: volume_button.checked || volume_button.pressed ? 1.0 : 0.5
                    background: Image {
                        width: scaleFfactor * 40
                        height: width
                        opacity: 1
                        anchors.centerIn: volume_button
                        source:  "qrc:/icons/videoplayer_volume_icon.png"
                    }

                    Rectangle {
                        id: volume_dialog
                        color: "#808080"
                        visible: volume_button.checked
                        width: scaleFfactor * 60
                        height: scaleFfactor * 150
                        radius: 10
                        x: volume_button.width / 2 - volume_dialog.width / 2
                        y: - scaleFfactor * 150
                        Slider {
                            id: control
                            value: mediaPlayer.volume
                            stepSize: 0.01
                            from: 0
                            to: 1.0
                            height: parent.height - 20
                            width: parent.width
                            anchors.centerIn: parent
                            orientation: Qt.Vertical
                            onValueChanged: { mediaPlayer.volume = value }
                            onPressedChanged: {}
                            background: Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: control.topPadding + control.availableHeight / 2 - height / 2
                                implicitWidth: 10
                                implicitHeight: 200
                                height: control.availableHeight
                                width: implicitWidth
                                radius: 2
                                color: "white"

                                Rectangle {
                                    height: control.visualPosition * parent.height
                                    width: parent.width
                                    color: "#38383a"
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                y: control.topPadding + control.visualPosition * (control.availableHeight - height)
                                anchors.horizontalCenter: parent.horizontalCenter
                                implicitWidth: 40
                                implicitHeight: 40
                                radius: 20
                                color: control.pressed ? "#f0f0f0" : "#f6f6f6"
                                border.color: "gray"
                            }
                        }
                    }
                }
            }
        }
    }
}
