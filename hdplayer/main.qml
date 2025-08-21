/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         main.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Window 2.15
import com.alientek.qmlcomponents 1.0
Window {
    visible: true
    width: Screen.desktopAvailableWidth + 1
    height: Screen.desktopAvailableHeight + 1
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    id: window
    x: 0
    y: 0
    Window {
        flags: Qt.FramelessWindowHint
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight
        color: "black"
        visible: window.visible
    }
    color: "transparent"
    Client {
        programmerName: "hdplayer"
    }
}
