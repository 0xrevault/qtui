/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ClockLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-05
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
Item {
    anchors.fill: parent
    SystemTime {
        id: systemTime
    }
    SwipeView {
        id: swipeView
        anchors.fill: parent
        orientation: Qt.Vertical
        ClockPage1 {}
        ClockPage2 {}
    }
    PageIndicator {
        rotation: 90
        id: indicator
        count: swipeView.count
        visible: true
        currentIndex: swipeView.currentIndex
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        delegate: indicator_delegate
        Component {
            id: indicator_delegate
            Rectangle {
                width: 20
                height: width
                color: swipeView.currentIndex !== index  ? "gray" : "white"
                radius: height / 2
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
