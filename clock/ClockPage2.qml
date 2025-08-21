/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ClockPage2.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-06
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.12
Item {
    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.margins: 40
        Rectangle {
            id: item1
            Layout.preferredWidth: appMainBody.width / 2
            Layout.preferredHeight: appMainBody.height - rowLayout.anchors.margins * 2
            radius: 50
            color: "#5577a6f3"

            Text {
                id: time
                text: systemTime.system_time
                anchors.centerIn: parent
                color: "#77a6f3"
                font.pixelSize: item1.height / 2.5
                font.bold: true
                font.letterSpacing: -15
                font.family: "Source Han Sans CN"
            }
        }
        ColumnLayout {
            Layout.leftMargin: 80
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Text {
                    id: week
                    anchors.verticalCenter: parent.verticalCenter
                    text: systemTime.system_week
                    color: "#77a6f3"
                    font.pixelSize: item1.height / 6
                    font.bold: true
                    font.family: "Source Han Sans CN"
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Text {
                    id: date
                    text: systemTime.system_date2
                    color: "#77a6f3"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: item1.height / 6
                    font.bold: true
                    font.family: "Source Han Sans CN"
                }
            }
        }
    }
}
