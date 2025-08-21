/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtMultimedia 5.12
Item {
    property real scaleFfactor: parent.width / 1024
    anchors.fill: parent

    Loader {
        active: true
        id: loader
        asynchronous: true
        anchors.fill: parent
        source: "VideoLayout.qml"
    }

    MediaPlayer {
        id: soundsPlayer
        source: "qrc:/sounds/sounds.wav"
    }
}
