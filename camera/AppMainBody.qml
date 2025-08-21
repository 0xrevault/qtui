/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-08-16
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
Rectangle {
    property real scaleFfactor: parent.width / 720
    anchors.fill: parent
    color: "black"

    Loader {
        active: true
        id: loader
        anchors.fill: parent
        asynchronous: true
        source: "CameraLayout.qml"
    }
    // Timer {
    //     interval: 500
    //     id: timer
    //     repeat: false
    //     running: true
    //     onTriggered: loader.active = true
    // }
}
