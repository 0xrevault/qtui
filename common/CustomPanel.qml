/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         CustomPanel.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-17
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtGraphicalEffects 1.12
Item {
    width: 250 * scaleFactor
    height: 250 * scaleFactor
    property real mRadius: 30
    property color mColor: "#404040"
    property real mOpacity: 0.8
    FuzzPanel {
        id: customPannelFuzzPanel
        target: fuzzPanel
        anchors.fill: parent
        radius: 50
        clip: true
        visible: false
        Rectangle {
            id: customPannelFuzzPanelRect
            opacity: mOpacity
            anchors.fill: parent
            radius: mRadius
            color: mColor
        }
    }

    OpacityMask {
        anchors.fill: customPannelFuzzPanel
        source: customPannelFuzzPanel
        maskSource: customPannelFuzzPanelRect
    }
}
