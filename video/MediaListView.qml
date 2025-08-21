/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         MediaListView.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-13
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.12
import com.alientek.qmlcomponents 1.0
Rectangle {
    anchors.fill: parent
    enabled: videoplayer.state === MediaPlayer.StoppedState

    Connections {
        target: videoplayer
        function onStateChanged(state) {
            if (state === MediaPlayer.PlayingState)
                mediaListView.visible = false
            if (state === MediaPlayer.StoppedState)
                mediaListView.visible = true
        }
    }
    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: videosGridView.contentHeight + videosGridView.cellWidth
        GridView  {
            id: videosGridView
            //anchors.fill: parent
            anchors.top: parent.top
            anchors.topMargin: 120 * scaleFfactor
            width: parent.width
            height: parent.height - 120 * scaleFfactor
            focus: true
            clip: false
            interactive: false
            cellWidth: videosGridView.width / 5
            cellHeight: videosGridView.width / 5
            snapMode: GridView.SnapOneRow
            currentIndex: -1
            model: mediaPlayList
            onCountChanged : {
                currentIndex = -1
            }
            delegate: Rectangle {
                id: itembg
                width: videosGridView.cellWidth
                height: videosGridView.cellWidth
                color: "transparent"
                Image {
                    id: photo
                    source: media.coverArtUrl
                    width: parent.width - 5
                    height: parent.height - 5
                    anchors.centerIn: parent
                    smooth: true
                    fillMode: Image.PreserveAspectCrop
                    Text {
                        text: secondsFormatTime(media.duration)
                        color: "white"
                        visible: !media.checked
                        font.pixelSize: 20 * scaleFfactor
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.rightMargin: 5
                    }
                    Image {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        width: 40 * scaleFfactor
                        height: width
                        visible: media.checked
                        source: "qrc:/icons/checked.png"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        videoplayer.source = media.sourceUrl
                        videoplayer.play()
                    }
                }
                Button {
                    id: selectButton
                    enabled: choseSwitchBt.checked
                    visible: choseSwitchBt.checked
                    anchors.fill: parent
                    checkable: true
                    checked: false
                    background: Rectangle {
                        anchors.fill: parent
                        opacity: 0.2
                        visible: media.checked
                    }
                    onCheckedChanged: {
                        if (media === undefined)
                            return
                        media.checked = selectButton.checked
                        if (selectButton.checked)
                            selectVideoCount++
                        else if (choseSwitchBt.checked)
                            selectVideoCount--
                    }
                }

                Connections {
                    target: choseSwitchBt
                    function  onCheckedChanged() {
                        if (!choseSwitchBt.checked) {
                            selectButton.checked = false
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: flickable.contentY >= scaleFfactor * 15
        anchors.top: parent.top
        width: parent.width
        height: scaleFfactor * 100
        opacity: 0.5
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Button {
        id: backBt
        anchors.left: parent.left
        anchors.leftMargin: 25 * scaleFfactor
        anchors.top: parent.top
        anchors.topMargin: 20 * scaleFfactor
        width: 64 * scaleFfactor
        height: width
        opacity: backBt.pressed ? 0.5 : 1.0
        background: Rectangle {
            anchors.fill: parent
            radius: height
            color: "#88101010"
            Image {
                anchors.centerIn: parent
                width: 40 * scaleFfactor
                height: width
                source: "qrc:/icons/back.png"
            }
        }
        onClicked: {
            // if (videoplayer.state === MediaPlayer.PlayingState || videoplayer.state === MediaPlayer.PausedState) {
            //     videoplayer.stop()
            //     return
            // }
            mediaListView.visible = false
            videoplayer.stop()
            cameraPlayer.play()
        }
    }

    property int selectVideoCount : 0
    Button {
        id: choseSwitchBt
        anchors.right: parent.right
        anchors.rightMargin: 25 * scaleFfactor
        anchors.top: parent.top
        anchors.topMargin: 20 * scaleFfactor
        width: choseSwitchBtText.width * 1.3
        height: scaleFfactor * 64
        checkable: true
        checked: false
        opacity: choseSwitchBt.pressed ? 0.5 : 1.0
        background: Rectangle {
            height: parent.height / 2 * 1.5
            width: parent.width
            anchors.centerIn: parent
            radius: height / 2
            color: "#88101010"
            Text {
                id: choseSwitchBtText
                text: choseSwitchBt.checked ? qsTr("取消") : qsTr("选择")
                font.pixelSize: 20 * scaleFfactor
                color: "white"
                anchors.centerIn: parent
            }
        }
        onCheckedChanged: {
            if (!choseSwitchBt.checked)
                selectVideoCount = 0
        }
        onClicked: {
            if (videoplayer.state === MediaPlayer.PlayingState) {
                videoplayer.stop()
                return
            }
        }
    }

    Text {
        text: qsTr("无录像文件")
        visible: mediaPlayList.count === 0
        anchors.centerIn: parent
        font.pixelSize: 25 * scaleFfactor
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 100 * scaleFfactor
        visible: choseSwitchBt.checked
        Text {
            id: selectCountText
            text: qsTr("已选择") + " " + selectVideoCount + " " + qsTr("个录像文件")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            font.pixelSize: 20　* scaleFfactor
        }

        Button {
            id: deleteBt
            width: 80 * scaleFfactor
            height: width
            anchors.right: parent.right
            anchors.rightMargin: 25 * scaleFfactor
            anchors.verticalCenter: selectCountText.verticalCenter
            opacity: deleteBt.pressed ? 0.8 : 1.0
            background: Image {
                width: scaleFfactor * 40
                height: width
                anchors.centerIn: parent
                source: "qrc:/icons/delete.png"
            }
            onClicked: {
                if (selectVideoCount !== 0)
                    deletePage.visible = true
            }
        }
    }

    DeletePage {
        anchors.fill: parent
        id: deletePage
        visible: false
        onDeleteButtonClicked: {
            mediaPlayList.deleteSelectVideoFiles()
            choseSwitchBt.checked = false
        }
    }
}

