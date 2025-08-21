/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         Widgets.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-12
* @link          http://www.alientek.com
*******************************************************************/
import QtQuick 2.12

Item {
    Text {
        id : time
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50 * scaleFfactor
        text: systemTime.system_time
        color: "white"
        font.pixelSize: 80 * scaleFfactor
    }

    Text {
        id : date
        anchors.top: time.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        text: systemTime.system_date2 + " " + systemTime.system_week
        color: "white"
        font.pixelSize: 30 * scaleFfactor
    }
}
