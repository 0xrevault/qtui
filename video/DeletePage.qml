/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   camera
* @brief         DeletePage.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-03-17
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.0
import QtQuick.Controls 2.12

Rectangle {
    color: "#33333333"
    anchors.fill: parent
    id: deletePage
    signal deleteButtonClicked()
    MouseArea {
        anchors.fill: parent
        onClicked: column1.y = parent.height
    }

    onVisibleChanged: {
        if (visible)
            column1.y = parent.height - scaleFfactor * 190
    }

    Column {
        id: column1
        y: parent.height
        Behavior on y { PropertyAnimation { duration: 100; easing.type: Easing.OutQuart } }
        width: parent.width - scaleFfactor * 80
        spacing: scaleFfactor * 10
        anchors.horizontalCenter: parent.horizontalCenter
        onYChanged: {
            if (y === parent.height)
                deletePage.visible = false
        }
        Button {
            id: deleteBt
            width: parent.width
            height: scaleFfactor * 80
            background: Rectangle {
                color: deleteBt.pressed ? "#DCDCDC" : "white"
                radius: scaleFfactor * 10
                anchors.fill: parent
                Text {
                    text: qsTr("删除选择的录像文件")
                    font.pixelSize: scaleFfactor * 30
                    anchors.centerIn: parent
                    color: "#e3170d"
                }
            }
            onClicked: {
                deleteButtonClicked()
                column1.y = deletePage.height
            }
        }

        Button {
            id: cancelBt
            width: parent.width
            height: scaleFfactor * 80
            background: Rectangle {
                radius: scaleFfactor * 10
                anchors.fill: parent
                color: cancelBt.pressed ? "#DCDCDC" : "white"
                Text {
                    text: qsTr("取消")
                    font.pixelSize: scaleFfactor * 30
                    anchors.centerIn: parent
                    color: "#007aff"
                    font.bold: true
                }
            }
            onClicked: column1.y = deletePage.height
        }
    }
}
