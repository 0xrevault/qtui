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
import QtQuick.Controls 2.12
Item {
    width: 280
    height: 280
    property real mRadius: 50
    property color mColor: "black"
    property real mOpacity: 0.5
    property Item mTarget
    signal okSignal()
    FuzzPanel {
        id: customPannelFuzzPanel
        target: mTarget
        anchors.fill: parent
        radius: mRadius
        clip: true
        visible: false
        Rectangle {
            id: customPannelFuzzPanelRect
            opacity: mOpacity
            anchors.fill: parent
            radius: mRadius * scaleFfactor
            color: mColor
        }
    }

    OpacityMask {
        anchors.fill: customPannelFuzzPanel
        source: customPannelFuzzPanel
        maskSource: customPannelFuzzPanelRect
        Rectangle {
            anchors.bottom: okBt.top
            width: parent.width
            height: 1
            color: "gray"
        }
        Button {
            id: okBt
            width: parent.width
            height: 60 * scaleFfactor
            anchors.bottom: parent.bottom
            background: CustomRectangle {
                anchors.fill: parent
                color: okBt.pressed ? "#CACACA" : "transparent"
                radius: mRadius * scaleFfactor
                radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                Text {
                    anchors.centerIn: parent
                    text: qsTr("感谢你的阅读")
                    font.pixelSize: 20 * scaleFfactor
                    color: "#3584e4"
                }
            }
            onClicked: okSignal()
        }
    }
}
