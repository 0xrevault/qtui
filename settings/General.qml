/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AnimationControl.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-26
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.5
import com.alientek.qmlcomponents 1.0
import QtQuick.Controls 2.12
//import QtQuick.Layouts 1.12
Item {
    SystemControl {
        id: systemControl
        Component.onCompleted: { systemControl.onSystemuiconfChanged(); systemControl.checkMemoryInfo() }
    }
    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height + 100
        Column {
            id: column
            anchors.top: parent.top
            anchors.topMargin: scaleFfactor * 50
            width: parent.width
            spacing: 10

            Text {
                font.pixelSize: scaleFfactor * 20
                text: qsTr("通用")
                color: "black"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: qsTr("系统语言")
                font.pixelSize: scaleFfactor * 20
            }

            RadioButton {
                id: radioButton1
                width: parent.width - 10
                height: scaleFfactor * 50
                text: qsTr("中文")
                checked: languageManager.language === 1
                onCheckedChanged: if (checked) languageManager.language = 1
                font.pixelSize: scaleFfactor * 20
                background: Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: radioButton1.down ? "#DDDDDD" : "white"
                }
                indicator: Image {
                    x: parent.width - 50
                    width: scaleFfactor * 25
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    source: radioButton1 .checked ? "qrc:/icons/wifi_connected_icon.png" : ""
                }
                contentItem: Text {
                    text: radioButton1.text
                    font: radioButton1.font
                    opacity: enabled ? 1.0 : 0.3
                    color: radioButton1.down ? "#4169e1" : "black"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    //leftPadding: radioButton1.indicator.width + radioButton1.spacing
                }
            }
            RadioButton {
                id: radioButton2
                width: parent.width - 10
                height: scaleFfactor * 50
                checked: languageManager.language === 2
                onCheckedChanged: if (checked) languageManager.language = 2
                text: qsTr("英语(English)")
                font.pixelSize: scaleFfactor * 20
                background: Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: radioButton2.down ? "#DDDDDD" : "white"
                }
                indicator: Image {
                    x: parent.width - 50
                    width: scaleFfactor * 25
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    source: radioButton2 .checked ? "qrc:/icons/wifi_connected_icon.png" : ""
                }
                contentItem: Text {
                    text: radioButton2.text
                    font: radioButton2.font
                    opacity: enabled ? 1.0 : 0.3
                    color: radioButton2.down ? "#4169e1" : "black"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    //leftPadding: radioButton1.indicator.width + radioButton2.spacing
                }
            }

            Text {
                font.pixelSize: scaleFfactor * 20
                text: qsTr("系统信息")
                color: "black"
                id: systemInfoText
                anchors.left: parent.left
                anchors.leftMargin: scaleFfactor * 10
            }

            Rectangle {
                radius: 10
                width: parent.width - 10
                height: scaleFfactor * 50

                Text {
                    font.pixelSize: scaleFfactor * 20
                    text: systemControl.memoryInfoMation
                    color: "black"
                    anchors.left: parent.left
                    anchors.leftMargin: scaleFfactor * 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: scaleFfactor * 10
                anchors.right: parent.right
                anchors.rightMargin: scaleFfactor * 5
                font.pixelSize: scaleFfactor * 15
                color: "#808A87"
                text: qsTr("注：市面上的储存容量与实际计算容量是有区别的。市面储存设备容量1KB=1000Byte,而在程序里实际容量1KiB＝1024Byte。注显示的为可用内存，不包括连续内存")
                wrapMode: Text.WrapAnywhere
            }

            Column {
                Button {
                    id: rebootBt
                    width: flickable.width - 10
                    height: scaleFfactor * 50
                    background: CustomRectangle {
                        radius: 10
                        anchors.fill: parent
                        radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop
                        color: rebootBt.pressed ? "#4169e1" : "white"
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 25
                            color: rebootBt.pressed ? "white" : "#4169e1"
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 20 * scaleFfactor
                            text: qsTr("重启")
                        }
                    }
                    onClicked: {
                        window.hide()
                        systemControl.systemReboot()
                        systemControl.uiKillall()
                    }
                }

                Button {
                    id: poweroffBt
                    width: flickable.width - 10
                    height: scaleFfactor * 50
                    background: CustomRectangle {
                        color: poweroffBt.pressed ? "#4169e1" : "white"
                        Rectangle {
                            height: 1
                            width: flickable.width - 25
                            anchors.right: parent.right
                            color: "#DCDCDC"
                        }
                        //radius: 10
                        anchors.fill: parent
                        //radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 25
                            color: poweroffBt.pressed ? "white" : "#4169e1"
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 20 * scaleFfactor
                            text: qsTr("关机")
                        }
                    }
                    onClicked: {
                        systemControl.systemPoweroff()
                    }
                }

                Button {
                    id: exitBt
                    width: flickable.width - 10
                    height: scaleFfactor * 50
                    background: CustomRectangle {
                        color: exitBt.pressed ? "#4169e1" : "white"
                        Rectangle {
                            height: 1
                            width: flickable.width - 25
                            anchors.right: parent.right
                            color: "#DCDCDC"
                        }
                        radius: 10
                        anchors.fill: parent
                        radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 25
                            color: exitBt.pressed ? "white" : "#4169e1"
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 20 * scaleFfactor
                            text: qsTr("退出")
                        }
                    }
                    onClicked: {
                        window.hide()
                        systemControl.uiKillall()
                        Qt.quit()
                    }
                }
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: scaleFfactor * 10
                anchors.right: parent.right
                anchors.rightMargin: scaleFfactor * 5
                font.pixelSize: scaleFfactor * 15
                color: "#808A87"
                text: qsTr("退出将关闭所有Qt程序，重启桌面UI请在串口终端上执行systemctl start systemui")
                wrapMode: Text.WrapAnywhere
            }
        }
    }
}
