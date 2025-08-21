/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    anchors.fill: parent
    color: "black"
    property real scaleFacter: window.width / 1024
    Loader {
        active: true
        asynchronous: true
        id: loader
        anchors.fill: parent
        source: "DashboardLayout.qml"
    }
}
