/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         LedLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-05
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import com.alientek.qmlcomponents 1.0
Item {
    anchors.fill: parent
    Rectangle {
        id: ledRectBg
        anchors.fill: parent
        color: ledControl.ledState === LedControl.On ?  "#1E90Ef" : "#202020"
    }

    Image {
        width: 120 * scaleFactor
        height: width
        id: flashlightImage
        source: ledControl.ledState === LedControl.On ? "qrc:/icons/flashlight_on.png" : "qrc:/icons/flashlight_off.png"
        anchors.centerIn: parent
        opacity: ledControl.ledState === LedControl.On ? 1.0 : 0.5
    }

    Text {
        anchors.horizontalCenter: flashlightImage.horizontalCenter
        anchors.top: flashlightImage.bottom
        text: ledControl.ledState === LedControl.On ? qsTr("电筒开") : qsTr("电筒关")
        color: "white"
        font.pixelSize: 20 * scaleFactor
        opacity: ledControl.ledState === LedControl.On ? 1.0 : 0.5
    }

    LedControl {
        id: ledControl
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            ledControl.ledState = !ledControl.ledState
        }
    }
}
