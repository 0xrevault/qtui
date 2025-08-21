/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         VideoDisplay.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-12
* @link          http://www.alientek.com
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.12
import com.alientek.qmlcomponents 1.0
Item {
    anchors.fill: parent
    id: videoDisplay
    visible: false

    Connections {
        target: videoplayer
        function onDurationChanged() {
            media_play_Hprogress.to = videoplayer.duration
        }

        function onPositionChanged() {
            media_play_Hprogress.value = videoplayer.position
        }
        function onStateChanged(state) {
            if ( videoplayer.state === MediaPlayer.PlayingState) {
                playStateRect.opacity = 0
            } else   {
                playStateRect.opacity = 1
            }
            if (state === MediaPlayer.PlayingState) {
                videoDisplay.visible = true
                middleWidget.visible = false
            }
            if (state === MediaPlayer.StoppedState) {
                middleWidget.visible = true
                videoDisplay.visible = false
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

    Item {
        id: playPanel
        //visible: videoplayer.state === MediaPlayer.PlayingState || videoplayer.state === MediaPlayer.PausedState
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            Rectangle {
                id: playStateRect
                anchors.centerIn: parent
                width: 80 * scaleFfactor
                height: width
                radius: height
                color: "#88101010"
                Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Linear } }
                Image {
                    source:  videoplayer.state === MediaPlayer.PlayingState ? "qrc:/icons/play.png" : "qrc:/icons/pause.png"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                if ( videoplayer.state === MediaPlayer.PlayingState) {
                    videoplayer.pause()
                } else if (videoplayer.state === MediaPlayer.PausedState) {
                    videoplayer.play()
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30 * scaleFfactor
            Text{
                id: playTimePosition
                anchors.verticalCenter: parent.verticalCenter
                text: currentMediaTime(videoplayer.position)
                color: "white"
                font.pixelSize: scaleFfactor * 20
                font.bold: true
            }

            Slider {
                id: media_play_Hprogress
                height: 80 * scaleFfactor
                width: playPanel.width - scaleFfactor * 200
                from: 0
                stepSize: 10
                orientation: Qt.Horizontal
                onPressedChanged: {
                    if (!media_play_Hprogress.pressed && videoplayer.seekable) {
                        videoplayer.setPosition(value)
                        videoplayer.play()
                    }
                }

                onValueChanged: {

                }
                background: Rectangle {
                    x: media_play_Hprogress.leftPadding
                    y: media_play_Hprogress.topPadding + media_play_Hprogress.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 8
                    width: media_play_Hprogress.availableWidth
                    height: 8
                    radius: 0
                    color: "#38383a"

                    Rectangle {
                        width: media_play_Hprogress.visualPosition * parent.width
                        height: parent.height
                        color: "#7a7a7c"
                        radius: 0
                    }
                }

                handle: Rectangle {
                    x: media_play_Hprogress.leftPadding + media_play_Hprogress.visualPosition * (media_play_Hprogress.availableWidth - width)
                    y: media_play_Hprogress.topPadding + media_play_Hprogress.availableHeight / 2 - height / 2
                    implicitWidth: 20
                    implicitHeight: 20
                    color: "transparent"
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        color: "#ffffff"
                        radius: width / 2
                        Rectangle {
                            visible: false
                            anchors.centerIn: parent
                            color: "#ffffff"
                            width: parent.width - 8
                            height: width
                            radius: width / 2
                            Rectangle {
                                anchors.centerIn: parent
                                color: "#8dcff4"
                                width: 10
                                height: width
                                radius: width / 2
                            }
                        }
                    }
                }
            }

            Text{
                id: playTimeDuration
                anchors.verticalCenter: parent.verticalCenter
                text: currentMediaTime(videoplayer.duration)
                color: "white"
                font.pixelSize: scaleFfactor * 20
                font.bold: true
            }
        }
    }

    Button {
        id: backBt2
        anchors.left: parent.left
        anchors.leftMargin: 25 * scaleFfactor
        anchors.top: parent.top
        anchors.topMargin: 20 * scaleFfactor
        width: 64 * scaleFfactor
        height: width
        opacity: backBt2.pressed ? 0.5 : 1.0
        background: Rectangle {
            anchors.fill: parent
            radius: height
            color: "#AA888888"
            Image {
                anchors.centerIn: parent
                width: 40 * scaleFfactor
                height: width
                source: "qrc:/icons/back.png"
            }
        }
        onClicked: {
            if (videoplayer.state === MediaPlayer.PlayingState || videoplayer.state === MediaPlayer.PausedState) {
                videoplayer.stop()
                return
            }
            videoplayer.stop()
        }
    }
}
