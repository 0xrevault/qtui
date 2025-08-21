/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         CameraLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-23
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import com.alientek.qmlcomponents 1.0
Rectangle {
    property string objText: qsTr("功能介绍：此程序为目标检测程序，只能检测下面80类。调整“颜色”可以改变画框和文字的颜色，\
调整“阈值”可以改变识别精度。模型为256x256。摄像头采集的图像为640x480 30fps。全屏显示时，图像会拉伸，此现象为正常现象。") + "
80items: background,person,bicycle,car,motorcycle,airplane,bus,train,truck,boat,traffic light,fire hydrant\
stop sign,parking meter,bench,bird,cat,dog,horse,sheep,cow,elephant,bear,zebra,giraffe,backpack,umbrella,handbag,tie,suitcase,\
frisbee,skis,snowboard,sports ball,kite,baseball bat,baseball glove,skateboard,surfboard,tennis racket,bottle,wine glass,\
cup,fork,knife,spoon,bowl,banana,apple,sandwich,orange,broccoli,carrot,hot dog,pizza,donut,cake,chair,couch,potted plant,bed,dining table,toilet,\
tv,laptop,mouse,remote,keyboard,cell phone,microwave,oven,toaster,sink,refrigerator,book,clock,vase,scissors,teddy bear,hair drier,toothbrush"

    anchors.fill: parent
    color: "black"

    Timer {
        id: delayToexec
        repeat: false
        function setTimeout(func, delayTime) {
            delayToexec.stop()
            delayToexec.interval = delayTime
            delayToexec.triggered.connect(func)
            delayToexec.triggered.connect(function release () {
                delayToexec.triggered.disconnect(func)
                delayToexec.triggered.disconnect(release)
            })
            delayToexec.start()
        }
    }


    Camera {
        id: camera
        Component.onCompleted: camera.play()
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: camera.image
    }

    NnThread {
        id: nnThread
        image: camera.image
        onDrawMarksChanged: {
            drawMarksItem.marks = marks
        }
    }

    DrawMarksItem {
        id: drawMarksItem
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: camera.isp_ctrl()
    }

    ListModel {
        id: colorListModel
        ListElement {
            mcolor: "#ff0000"
        }
        ListElement {
            mcolor: "#ffffff"
        }
        ListElement {
            mcolor: "#00ff00"
        }
        ListElement {
            mcolor: "#0000ff"
        }
    }
    ListModel {
        id: confidenceThreshModel
        ListElement {
            confidenceThresh: 0.7
        }
        ListElement {
            confidenceThresh: 0.6
        }
        ListElement {
            confidenceThresh: 0.5
        }
        ListElement {
            confidenceThresh: 0.4
        }
    }


    Rectangle {
        id: colorRect
        width: colorText.width * 1.2
        height: 50 * scaleFfactor
        //radius: height / 4
        anchors.left: parent.left
        anchors.bottom: tumbler.top
        color: "#88101010"
        Text {
            id: colorText
            text: qsTr("颜色")
            font.pixelSize: 25 * scaleFfactor
            anchors.centerIn: parent
            color: "white"
        }
    }
    Tumbler {
        id: tumbler
        width: 100 * scaleFfactor
        height: parent.height / 2
        anchors.horizontalCenter: colorRect.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        model: colorListModel
        visibleItemCount: 4
        wrap: true
        currentIndex: 0
        onCurrentIndexChanged: {
            drawMarksItem.color = colorListModel.get(currentIndex).mcolor
        }
        delegate: Item {
            width: 80 * scaleFfactor
            height: width
            Rectangle {
                width: tumbler.currentIndex === index ? 40 * scaleFfactor : 30 * scaleFfactor
                height: width
                radius: height
                color: mcolor
                opacity: tumbler.currentIndex === index ? 1.0 : 0.3
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: tumbler.currentIndex = index
            }
        }
    }

    Rectangle {
        id: thresholdRect
        width: thresholdText.width * 1.2
        height: 50 * scaleFfactor
        anchors.right: parent.right
        //radius: height / 4
        anchors.bottom: tumbler1.top
        color: "#88101010"
        Text {
            id: thresholdText
            text: qsTr("阈值")
            font.pixelSize: 25 * scaleFfactor
            anchors.centerIn: parent
            color: "white"
        }
    }
    Tumbler {
        id: tumbler1
        width: 100 * scaleFfactor
        height: parent.height / 2
        anchors.horizontalCenter: thresholdRect.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        model: confidenceThreshModel
        visibleItemCount: 4
        wrap: true
        currentIndex: 0
        onCurrentIndexChanged: {
            nnThread.confidenceThresh = confidenceThreshModel.get(currentIndex).confidenceThresh
        }
        delegate: Item {
            width: 80 * scaleFfactor
            height: width
            opacity: tumbler1.currentIndex === index ? 1.0 : 0.6
            Rectangle {
                width: tumbler1.currentIndex === index ? 40 * scaleFfactor : 30 * scaleFfactor
                height: width
                radius: height
                color: "#88404040"
                anchors.centerIn: parent
                Text {
                    anchors.centerIn: parent
                    text: confidenceThresh
                    font.pixelSize: tumbler1.currentIndex === index ? 20 * scaleFfactor : 15 * scaleFfactor
                    color: "white"
                    font.bold: true
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: tumbler1.currentIndex = index
            }
        }
    }
    Rectangle {
        id: leftBottomRect
        color: "#88101010"
        width: column.width * 1.2
        height: column.height * 1.2
        anchors.bottom: parent.bottom
        Column {
            id: column
            anchors.centerIn: parent
            // 注：同时打开可能会卡顿前几秒？所以用定时器开启
            // Text {
            //     id: infoText1
            //     //text: "推理耗时:" + nnThread.inferenceTime + "ms"
            //     color: "white"
            //     font.pixelSize: 25 * scaleFfactor
            // }

            Text {
                id: infoText2
                //text: "推理帧率:" + nnThread.inferenceFrameRate + "fps"
                color: "white"
                font.pixelSize: 25 * scaleFfactor
            }

            Text {
                id: infoText3
                //text: "显示帧率:" + videoOutput.frameRateInfo + "fps"
                color: "white"
                font.pixelSize: 25 * scaleFfactor
            }
        }
    }

    Timer {
        repeat: true
        interval: 6000
        running: true
        onTriggered: {
            infoText3.text = qsTr("显示帧率:") + videoOutput.frameRateInfo + "fps"
        }
    }

    Timer {
        repeat: true
        interval: 10000
        running: true
        onTriggered: {
            infoText2.text = qsTr("推理帧率:") + nnThread.inferenceFrameRate + "fps"
        }
    }

    Button {
        id: abountBt
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 150 * scaleFfactor
        height: 100 * scaleFfactor

        background: Rectangle {
            anchors.fill: parent
            opacity: abountBt.pressed ? 0.8 : 1.0
            color: "#88101010"
            Text {
                text: qsTr("详细信息")
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 22 * scaleFfactor
            }
        }
        onClicked: dialog.open()
    }

    Rectangle { anchors.centerIn: title
        color: "#88101010"
        width: title.width * 1.2
        height: title.height * 1.2
    }

    Text {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("目标检测Ai演示程序")
        anchors.top: parent.top
        font.pixelSize: 25 * scaleFfactor
        color: "yellow"
        font.bold: true
    }

    Dialog {
        id: dialog
        modal: true
        width: 500 * scaleFfactor
        height: 400 * scaleFfactor
        anchors.centerIn: parent
        background: Rectangle {
            anchors.fill: parent
            radius: 10 * scaleFfactor
            border.width: 1
            border.color: "#DCDCDC"
            Button {
                id: infoCloseBt
                width: 50 * scaleFfactor
                height: width
                anchors.right: parent.right
                anchors.bottom: parent.top
                anchors.bottomMargin: -width
                anchors.rightMargin: -width
                opacity: infoCloseBt.pressed ? 0.8 : 1.0
                background: Image {
                    anchors.centerIn: parent
                    width: 30 * scaleFfactor
                    height: width
                    source: "qrc:/icons/close.png"
                }
                onClicked: dialog.close()
            }
        }
        Flickable {
            anchors.top: parent.top
            anchors.topMargin: 20
            width: parent.width
            anchors.bottom: parent.bottom
            contentHeight: info.height + 1
            clip: true
            Text {
                id: info
                width: parent.width
                wrapMode: Text.WrapAnywhere
                text: objText
                font.pixelSize: 25 * scaleFfactor
                lineHeight: 40 * scaleFfactor
                lineHeightMode: Text.FixedHeight
            }
        }
    }
}
