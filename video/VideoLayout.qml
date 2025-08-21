/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         VideoLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-04
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0

Item {
    anchors.fill: parent
    id: videoLayout

    property string recordCmd: "gst-pipeline: v4l2src device=/dev/video-camera1 ! video/x-raw,format=RGB16,width=640,height=480,framerate=30/1 ! encodebin profile=\"video/x-h264|element-properties,rate-control=0,qp-min=30,qp-max=30\" ! filesink location=%1"
    MediaPlayer {
        id: cameraPlayer
        source: "gst-pipeline: v4l2src device=/dev/video-camera0 ! video/x-raw, format=RGB16, width=640,height=480, framerate=30/1 ! waylandsink fullscreen=true"
        Component.onCompleted: cameraPlayer.play()
        mode: MediaPlayer.PlayCameraMode
    }

    MediaPlayer {
        id: videoRecorder
        path: appCurrtentDir + "/resource/videos/cameravideos/"
        //source: recordCmd
        mode: MediaPlayer.RecordMode
        onVideoFileChanged: mediaPlayList.updateModel()
    }

    MediaPlayer {
        id: videoplayer
        Component.onCompleted: videoplayer.play()
        mode: MediaPlayer.PlayVideoMode
    }

    MediaPlayerList {
        id: mediaPlayList
        sourcePath: appCurrtentDir + "/resource/videos/"

        Component.onCompleted: {
            // attention! Will cause obstruction
            mediaPlayList.updateModel()
        }
        onCountChanged: {
            if (mediaPlayList.count !== 0)
                coverArtImage.source = mediaPlayList.data(mediaPlayList.index(mediaPlayList.count - 1, 0), 257).coverArtUrl
            else
                coverArtImage.source = ""
        }
    }

    Item {
        visible: middleWidget.visible
        width: 80 * scaleFfactor
        height: parent.height

        Rectangle {
            anchors.centerIn: parent
            width: titleText.height * 1.5
            height: titleText.width * 1.5
            color: "#AA808080"
            radius: width / 2
            Text {
                id: titleText
                anchors.centerIn: parent
                rotation: 270
                font.pixelSize: 25 * scaleFfactor
                text: videoRecorder.state == MediaPlayer.PlayingState ? secondsFormatTime(timeCount) : "480P · 30fps"
                color: "white"
            }
        }
    }

    property int timeCount: 0
    Timer {
        id: timeCounttimer
        repeat: true
        interval: 1000
        onTriggered: timeCount++
    }

    Item {
        id: middleWidget
        anchors.right: parent.right
        width: 100 * scaleFfactor
        height: parent.height

        Column {
            spacing: 100 * scaleFfactor
            anchors.centerIn: parent
            Item {
                visible: !recorderRoundButton.checked
                height: width
                width: scaleFfactor * 80
            }
            RoundButton {
                id: recorderRoundButton
                width: scaleFfactor * 84
                height: width
                checkable: true
                checked: false
                background: Rectangle {
                    anchors.fill: parent
                    radius:  height / 2
                    border.color: "white"
                    border.width: scaleFfactor * 4
                    color: "transparent"
                    Rectangle {
                        width: recorderRoundButton.checked ? scaleFfactor * 60 : scaleFfactor * 70
                        height: recorderRoundButton.checked ? scaleFfactor * 60 : scaleFfactor * 70
                        Behavior on width { PropertyAnimation { duration: 200; easing.type: Easing.Linear } }
                        Behavior on height { PropertyAnimation { duration: 200; easing.type: Easing.Linear } }
                        Behavior on radius { PropertyAnimation { duration: 200; easing.type: Easing.Linear } }
                        color: "red"
                        radius: recorderRoundButton.checked ? scaleFfactor * 30 : scaleFfactor * 35
                        anchors.centerIn: parent
                    }
                }
                onCheckedChanged: {
                    if (recorderRoundButton.checked) {
                        timeCounttimer.start()
                        videoRecorder.source = recordCmd
                        videoRecorder.play()
                    } else {
                        videoRecorder.stop()
                        timeCounttimer.stop()
                        timeCount = 0
                    }
                }
                onClicked: soundsPlayer.play()
            }

            Button {
                height: width
                width: scaleFfactor * 80
                visible: !recorderRoundButton.checked
                background: Rectangle {
                    id: coverArtImageRect
                    anchors.fill: parent
                    radius: 5
                    visible: false
                    Image {
                        visible: false
                        anchors.fill: parent
                        id: coverArtImage
                        //source:  mediaPlayList.data(mediaPlayList.index(0, 0), 257).coverArtUrl
                    }
                }
                OpacityMask {
                    source: coverArtImage
                    anchors.fill: parent
                    maskSource: coverArtImageRect
                }
                onClicked: {
                    cameraPlayer.stop()
                    mediaListView.visible = true
                }
            }
        }
    }

    function secondsFormatTime(time){
        var sec = Math.floor(time);
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
        return /*hh+":"*/ + mm + ":" + ss
    }

    MediaListView {
        id: mediaListView
        visible: false
    }

    VideoDisplay{}
}
