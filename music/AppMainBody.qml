/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-07
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.0
import com.alientek.qmlcomponents 1.0
Item {
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "white"
    }

    Audio {
        id: musicPlayer
        source: ""
        volume: 0.5
        objectName: "myAudio"
        autoPlay: false
    }

    Loader {
        active: true
        id: loader
        anchors.fill: parent
        asynchronous: true
        source: "MusicLayout.qml"
    }
}
