/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         CustomDialog.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-02
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.15
Rectangle {
    id: customDialog
    anchors.fill: parent
    color: modal ? "#22101010" : "transparent"
    property bool modal: false
    property string title: ""
    property string subTitle: ""
    visible: false
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: customDialog.visible = false
    }
    function open() {
        customDialog.visible = true
    }
    function close() {
        customDialog.visible = false
    }
    Rectangle {
        id: rectContent
        anchors.centerIn: parent
        radius: height / 8
        width: 300 * scaleFfactor
        height: 150 * scaleFfactor
        ColumnLayout {
            anchors.fill: rectContent
            Text {
                Layout.preferredHeight : rectContent.height / 3 * 1.5
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                id: text1
                text: title
                font.bold: true
                font.pixelSize: scaleFfactor * 20
            }
            Text {
                Layout.preferredHeight : rectContent.height / 3 * 0.5
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                id: text2
                text: subTitle
                font.bold: true
                font.pixelSize: scaleFfactor * 15
                color: "#808A87"
            }
            CustomRectangle {
                Layout.preferredHeight : rectContent.height / 3
                Layout.fillWidth: true
                radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                radius: rectContent.radius
                color: mouseArea.pressed ? "#F8F8F8" : "white"
                Rectangle {
                    height: 1
                    width: parent.width
                    color: "#C0C0C0"
                }
                Text {
                    anchors.centerIn: parent
                    text: "好"
                    color: "#4169E1"
                    font.pixelSize: scaleFfactor * 20
                }
            }
        }
    }
}
