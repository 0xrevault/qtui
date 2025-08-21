/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0
import QtQuick.VirtualKeyboard 2.4
import QtQuick.VirtualKeyboard.Settings 1.2

Rectangle {
    anchors.fill: parent
    color: "#e6e5e5"

    Loader {
        active: true
        asynchronous: true
        id: loader
        anchors.fill: parent
        source: "ChatLayout.qml"
    }
}
