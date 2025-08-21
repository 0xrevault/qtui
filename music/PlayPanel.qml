/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   music
* @brief         PlayPanel.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-05-04
*******************************************************************/
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtMultimedia 5.0
ColumnLayout {
    anchors.fill: parent
    id: playPanel
    Connections {
        target: musicLayout
        function onProgress_maximumValueChanged()  {
            progress_control.to = progress_maximumValue
        }

        function onProgress_valueChanged() {
            progress_control.value = progress_value
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: -20
        Layout.preferredHeight: parent.height / 4
        Button {
            id: btn_volumedownBt
            Layout.preferredHeight: 50 * scaleFactor
            Layout.preferredWidth: Layout.preferredHeight
            opacity: btn_volumedownBt.pressed ? 0.5 : 1.0
            background: Image {
                source: "qrc:/icons/btn_volumedown.png"
                width: 40 * scaleFactor
                height: width
                anchors.centerIn: parent
            }
            onClicked:{
                volume_control.value -= 0.05
            }
        }
        Slider {
            id: volume_control
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * scaleFactor
            from: 0
            live: true
            to: 1
            stepSize: 0.01
            value: musicPlayer.volume
            onValueChanged: {
                musicPlayer.volume = value
            }
            background: Rectangle {
                x: volume_control.leftPadding
                y: volume_control.topPadding + volume_control.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 8
                width: volume_control.availableWidth
                height: 15 * scaleFactor
                radius: height / 2
                color: "#88DDDDDD"

                Rectangle {
                    width: volume_control.visualPosition * parent.width
                    height: parent.height
                    color: "white"
                    radius: height / 2
                }
            }

            handle: Item{ }
        }

        Button {
            id: btn_volumeupBt
            Layout.preferredHeight: 50 * scaleFactor
            Layout.preferredWidth: Layout.preferredHeight
            opacity: btn_volumeupBt.pressed ? 0.5 : 1.0
            background: Image {
                source: "qrc:/icons/btn_volumeup.png"
                width: 40 * scaleFactor
                height: width
                anchors.centerIn: parent
            }
            onClicked:{
                volume_control.value += 0.05
            }
        }
    }

    Lyric {
        id: lyric
        Layout.fillWidth: true
        height: parent.height / 6
        Layout.preferredHeight: parent.height / 6
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 3.5
        RowLayout {
            height: parent.height / 2
            anchors.centerIn: parent
            Layout.fillWidth: true
            spacing: 80 * scaleFactor
            Button {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                id: btn_previous
                background: Item {
                    anchors.fill: parent
                    Image {
                        width: 80 * scaleFactor
                        height: width
                        source: "qrc:/icons/btn_previous.png"
                        anchors.centerIn: parent
                    }
                    opacity: btn_previous.pressed ? 0.5 : 1.0
                }
                onClicked: previousBtnSignal()
            }

            Button {
                id: btn_play
                Layout.preferredWidth: 80 * scaleFactor
                Layout.preferredHeight: Layout.preferredWidth
                background: Item {
                    anchors.fill: parent
                    Image {
                        width: 80 * scaleFactor
                        height: width
                        source: musicPlayer.playbackState === Audio.PlayingState ? "qrc:/icons/btn_pause.png" : "qrc:/icons/btn_play.png"
                        anchors.centerIn: parent
                    }
                }
                onClicked: playBtnSignal()
            }

            Button {
                id: btn_next
                Layout.preferredWidth: 80 * scaleFactor
                Layout.preferredHeight: Layout.preferredWidth
                background: Item {
                    anchors.fill: parent
                    Image {
                        source: "qrc:/icons/btn_next.png"
                        anchors.centerIn: parent
                        width: 80 * scaleFactor
                        height: width
                    }
                    opacity: btn_next.pressed ? 0.5 : 1.0
                }
                onClicked: nextBtnSignal()
            }
        }
    }
    Item {
        Layout.preferredHeight: parent.height / 5
        Layout.fillWidth: true
        Slider {
            id: progress_control
            stepSize: 100
            width: parent.width
            anchors.centerIn: parent
            height: 40 * scaleFactor
            property bool handled: false
            from: 0
            live: false
            to: 1000
            value: 0
            onPressedChanged: {
                handled = true
                progress_pressed = progress_control.pressed
            }

            onValueChanged: {
                if (handled && musicPlayer.seekable) {
                    music_lyricModel.findIndex(value)
                    musicPlayer.seek(value)
                    musicPlayer.play()
                    handled = false
                } else {
                    music_lyricModel.getIndex(value)
                }
            }
            background: Rectangle {
                x: progress_control.leftPadding
                y: progress_control.topPadding + progress_control.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 8
                width: progress_control.availableWidth
                height: 15 * scaleFactor
                radius: height / 2
                color: "#88DDDDDD"

                Rectangle {
                    width: progress_control.visualPosition * parent.width
                    height: parent.height
                    color: "white"
                    radius: height / 2
                }
            }

            handle: Item{ }

            Text{
                id: playPanel_play_left_time
                anchors.left: progress_control.left
                anchors.leftMargin: 5
                anchors.top: progress_control.bottom
                anchors.topMargin: -5 * scaleFactor
                visible: true
                anchors.verticalCenter: progress_control.verticalCenter
                text: currentMusicTime(progress_value)
                color: "#D0D0D0"
                font.pixelSize: 20 * scaleFactor
            }

            Text{
                id: playPanel_play_right_time
                anchors.right: progress_control.right
                anchors.top: progress_control.bottom
                anchors.topMargin: -5 * scaleFactor
                anchors.rightMargin: 5
                visible: true
                anchors.verticalCenter: progress_control.verticalCenter
                text: currentMusicTime(progress_maximumValue)
                color: "#D0D0D0"
                font.pixelSize: 20 * scaleFactor
            }
        }
    }
}
