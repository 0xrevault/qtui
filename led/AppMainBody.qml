/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import com.alientek.qmlcomponents 1.0
Rectangle {
    anchors.fill: parent
    color: "#202020"
    property real scaleFactor: window.width / 720
    Loader {
        active: true
        asynchronous: true
        id: loader
        anchors.fill: parent
        source: "LedLayout.qml"
    }
    // Timer {
    //     interval: 300
    //     id: timer
    //     repeat: false
    //     running: true
    //     onTriggered: loader.active = true
    // }
}
