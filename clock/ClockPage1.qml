/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ClockPage1.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-07-27
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.12
Item {
    Row {
        anchors.centerIn: parent
        Text {
            text: systemTime.system_hour
            color: "#70de89"
            font.pixelSize: 400 * scaleFfactor
            font.bold: true
            font.family: "975Maru SC"
        }
        Text {
            text: systemTime.system_minutes.substring(0, 1)
            color: "#8870de89"
            font.pixelSize: 400 * scaleFfactor
            font.bold: true
            font.family: "975Maru SC"
        }
        Text {
            text: systemTime.system_minutes.substring(1, 2)
            color: "#70de89"
            font.pixelSize: 400 * scaleFfactor
            font.bold: true
            font.family: "975Maru SC"
        }

    }

    Connections {
        target: systemTime
        function onSystemTimeTriggered() {
            column.visible = !column.visible
        }
    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 100
        Rectangle {
            width: 100 * scaleFfactor
            height: width
            radius: height / 2
        }
        Rectangle {
            width: 100 * scaleFfactor
            height: width
            radius: height / 2
        }
    }
}
