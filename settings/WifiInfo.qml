/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         WifiInfo.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-08-30
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import Connman 0.2
import QtQuick.Controls 2.15
Item {
    id: wifiInfo
    Button {
        id: backBt
        anchors.topMargin: 50 * scaleFfactor
        anchors.top: parent.top
        width: image.width + nameW.width
        height: 40 * scaleFfactor
        opacity: backBt.pressed ? 0.8 : 1.0
        onClicked: {
            wifiPageSwipeView.currentIndex = 0
        }
        background: Row {
            id: row
            Image {
                id: image
                source: "qrc:/icons/back.png"
                anchors.verticalCenter: parent.verticalCenter
                height: width
                width: 30 * scaleFfactor
                fillMode: Image.PreserveAspectFit
            }
            Text {
                id: nameW
                text: qsTr("无线局域网")
                color: "#4169e1"
                font.pixelSize: scaleFfactor * 20
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Text {
        font.pixelSize: scaleFfactor * 20
        text: ns.name
        color: "black"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        font.bold: true
        anchors.topMargin: 50 * scaleFfactor
    }

    Timer {
        id: delayToRemoveServiesTimer
        interval: 200
        repeat: false
        running: false
        onTriggered: {
            wifiServicesSettings.remove()
        }
    }

    Connections {
        target: ns
        function onPathChanged() {
            wifiServicesSettings.path = ns.path
        }
        function onNameChanged() {
            wifiServicesSettings.name = ns.name
        }
    }

    Flickable {
        anchors.top: backBt.bottom
        anchors.topMargin: scaleFfactor * 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: column.height + scaleFfactor *  30
        clip: true
        Column {
            id: column
            spacing: 35 * scaleFfactor
            Button {
                id: btIgnore
                width: wifiInfo.width
                height: scaleFfactor * 50
                visible: ns.active
                background: Rectangle {
                    radius: 10
                    color: btIgnore.pressed ? "#DCDCDC" : "white"
                    Text {
                        color: "#4169e1"
                        anchors.left: parent.left
                        anchors.leftMargin: scaleFfactor * 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("忽略此网络")
                        font.pixelSize: scaleFfactor * 20
                    }
                }
                onClicked: {
                    // wifiServicesSettings.name = ns.name
                    // wifiServicesSettings.path = ns.path
                    // modelConnectedServices.data(modelConnectedServices.index(0, 0), 257).requestDisconnect()
                    // modelConnectedServices.data(modelConnectedServices.index(0, 0), 257).remove()
                    ns.requestDisconnect()
                    ns.remove()
                    delayToRemoveServiesTimer.restart()
                    wifiPageSwipeView.currentIndex = 0
                }
            }

            Button {
                id: btJoin
                visible: !ns.connected
                width: wifiInfo.width
                height: scaleFfactor * 50
                background: Rectangle {
                    radius: 10
                    color: btJoin.pressed ? "#DCDCDC" : "white"
                    Text {
                        color: "#4169e1"
                        anchors.left: parent.left
                        anchors.leftMargin: scaleFfactor * 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("加入此网络")
                        font.pixelSize: scaleFfactor * 20
                    }
                }
                onClicked: {
                    if (ns.active)
                        ns.requestConnect()
                    else {
                        actionSheet.open()
                    }
                    wifiPageSwipeView.currentIndex = 0
                }
            }
        }
    }
}
