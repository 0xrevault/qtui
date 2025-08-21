/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   key
* @brief         KeyLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-11-28
*******************************************************************/
import QtQuick 2.0
import com.alientek.qmlcomponents 1.0
Rectangle {
    anchors.fill: parent
    property int colorIndex: 6
    color: colors[colorIndex]
    property var colors: [
            "#FF0000", // 红色
            "#00FF00", // 绿色
            "#0000FF", // 蓝色
            "#FFFF00", // 黄色
            "#FF00FF", // 品红
            "#00FFFF", // 青色
            "#C0C0C0"  // 银色
        ]
    KeyInputEventThread {
        id: keyInputEventThread
        onKeyEvent: {
            switch(code) {
            case Qt.Key_1:
                if (value === true) {
                    keyImage.opacity = 1
                    if (colorIndex + 1 >= 7)
                        colorIndex = 0
                    else
                        colorIndex++
                } else if ((value === false)) {
                    keyImage.opacity = 0.5
                }
                break;
            default:
                break;
            }
        }
    }
    Image {
        id: keyImage
        anchors.centerIn: parent
        width: 128 * scaleFactor
        height: width
        source: "qrc:/icons/key.png"
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: keyImage.bottom
        anchors.topMargin: 25
        text: qsTr("请按下板载KEY按键")
        font.pixelSize: 25 * scaleFactor
    }
}
