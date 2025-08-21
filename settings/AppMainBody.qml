/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import Connman 0.2
import com.alientek.qmlcomponents 1.0
import QtQuick.Controls 2.15
import QtQuick.VirtualKeyboard 2.2
import QtQuick.VirtualKeyboard.Settings 2.2
Rectangle {
    anchors.fill: parent
    property real scaleFfactor: appMainBody.width / 1024

    // Text {
    //     text: "页面加载中请稍候..."
    //     anchors.centerIn: parent
    //     font.pixelSize: scaleFfactor * 20
    // }

    Loader {
        active: false
        id: loader
        anchors.fill: parent
        source: "SettingsLayout.qml"
    }
    Timer {
        interval: 500
        id: timer
        repeat: false
        running: true
        onTriggered: loader.active = true
    }

    /*onVisibleChanged: {
        if (visible && loader.status !== Loader.Ready) {
            loader.source = "SettingsLayout.qml"
            timer.restart()
        }
    }

    Connections {
        target: common
        function onBackToSystemUi() {
            loader.source = ""
            loader.active = false
        }
    }*/
}
