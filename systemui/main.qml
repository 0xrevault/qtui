/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         main.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-07
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.12
import com.alientek.qmlcomponents 1.0
Window {
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true
    property real scaleFfactor: window.width / 720
    flags: Qt.FramelessWindowHint
    x: 0
    y: 0
    id: window

    function translateText(text) {
        const translations = {
            "相机": qsTr("相机"),
            "目标检测": qsTr("目标检测"),
            "音乐": qsTr("音乐"),
            "记事本": qsTr("记事本"),
            "照片": qsTr("照片"),
            "视频": qsTr("视频"),
            "设置": qsTr("设置"),
            "测试": qsTr("测试"),
            "异核通信": qsTr("异核通信"),
            "人体关键点": qsTr("人体关键点"),
            "锁屏": qsTr("锁屏"),
            "录像机": qsTr("录像机"),
            "天气": qsTr("天气"),
            "时钟": qsTr("时钟"),
            "仪表盘": qsTr("仪表盘"),
            "仪表盘": qsTr("仪表盘"),
            "文件夹": qsTr("文件夹"),
            "按键": qsTr("按键"),
        };
        return translations[text] || text;
    }


    SystemUICommonApiServer {
        id: systemUICommonApiServer
        onAppAsktoHideOrShow: function(action) {
            if (action === SystemUICommonApiServer.Hide) {
                window.hide()
            }
            if (action === SystemUICommonApiServer.Show) {
                window.show()
                phonebg_scale.xScale = 1.0
                window.requestActivate()
                window.flags = Qt.FramelessWindowHint
                systemUICommonApiServer.currtentLauchAppName = ""
            }
        }
        onCurrtentLauchAppNameChanged: {
            if (systemUICommonApiServer.currtentLauchAppName === "null")
                systemUICommonApiServer.appAsktoHideOrShow(SystemUICommonApiServer.Show)
        }
    }

    function launchActivity(name, x, y, item, iconPath, currtentPage, launchMode) {
        window.flags = Qt.FramelessWindowHint |  Qt.WindowTransparentForInput
        systemUICommonApiServer.launchProperties(x, y, item.width, item.height, iconPath, currtentPage, launchMode)
        systemUICommonApiServer.launchApp(name)
    }

    Item {
        anchors.fill: parent
        id: desktop
        Item {
            id: rootItem
            anchors.fill: parent
            Image {
                id: phonebg
                anchors.centerIn: parent
                height: parent.height
                width: parent.width
                fillMode: Image.PreserveAspectCrop
                smooth: true
                source: "file://" + appCurrtentDir + "/src/ipad/ipad/ipad.jpg"
                transform: Scale {
                    id: phonebg_scale
                    origin.x: phonebg.width / 2
                    origin.y: phonebg.height / 2
                    Behavior on xScale { PropertyAnimation { duration: 50/*350*/; easing.type: Easing.Linear } }
                    xScale: 1.0
                    yScale: xScale
                }
                // Rectangle {
                //     anchors.fill: parent
                //     color: "#55404040"
                // }
            }
            Item {
                id: control_item
                width: window.width
                height: window.height

                SwipeView {
                    id: main_swipeView
                    visible: true
                    anchors.fill: parent
                    currentIndex: 1
                    clip: true
                    Widgets {}
                    Page1 {}
                    Page2 {}
                }
                Timer {
                    repeat: false
                    id: indicatorShowTimer
                    onTriggered: explainText.opacity = 1
                    interval: 1000
                }
                Connections {
                    target: main_swipeView
                    function onCurrentIndexChanged() {
                        explainText.opacity = 0
                        indicatorShowTimer.restart()
                    }
                }
                BottomApp {}
                PageIndicator {
                    id: indicator
                    count: main_swipeView.count
                    visible: main_swipeView.currentIndex !== 0
                    currentIndex: main_swipeView.currentIndex
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: scaleFfactor * 110
                    anchors.horizontalCenter: parent.horizontalCenter
                    delegate: indicator_delegate
                    Button {
                        width: 60 * scaleFfactor
                        height: 30 * scaleFfactor
                        anchors.centerIn: parent
                        id: explainBt
                        opacity: explainBt.pressed ? 0.5 : 1.0
                        background: Rectangle {
                            color: "#44ffffff"
                            anchors.fill: parent
                            radius: height / 2
                            Text {
                                Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
                                id: explainText
                                opacity: 1
                                text: qsTr("说明")
                                color: "white"
                                font.pixelSize: 12 * scaleFfactor
                                anchors.centerIn: parent

                            }
                        }
                        onClicked: {
                            dialog.width = window.width / 3 * 2
                            dialog.height = window.height / 3 * 2
                            dialog.x = (window.width - window.width / 3 * 2) / 2
                            dialog.y = (window.height - window.height / 3 * 2) / 2
                            dialog.open()
                            instructionsFileRead.readInstructions()
                        }
                    }
                    Component {
                        id: indicator_delegate
                        Rectangle {
                            opacity: 1 - explainText.opacity
                            width: scaleFfactor * 6
                            height: scaleFfactor * 6
                            color: main_swipeView.currentIndex !== index  ? "gray" : "#dddddd"
                            radius: scaleFfactor * 3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        SystemTime {
            id: systemTime
        }

        Row {
            visible: false
            height: 40 * scaleFfactor
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                id: timeText
                text: systemTime.system_time
                font.bold: false
                color: "white"
                font.pixelSize: window.width / 720 * 15
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                id: dateText
                text: systemTime.system_date2
                font.bold: false
                color: "white"
                font.pixelSize: window.width / 720 * 15
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                id: weekText
                text: systemTime.system_week
                font.bold: false
                color: "white"
                font.pixelSize: window.width / 720 * 15
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignVCenter
            }
            Item {
                Layout.fillWidth: true
            }
        }

        Dialog {
            id: dialog
            modal: true
            width: explainBt.width
            height: explainBt.height
            // Component.onCompleted: {
            //     dialog.x = explainBt.mapToGlobal(explainBt.x, explainBt.y).x
            //     dialog.y = explainBt.mapToGlobal(explainBt.x, explainBt.y).y
            // }
            background: CustomDialog {
                anchors.fill: parent
                mTarget: rootItem
                mRadius: 10 * scaleFfactor
                mColor: "#cccbc7"
                mOpacity: 0.9
                onOkSignal: {
                    dialog.close()
                }
            }
            Text {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("正点原子官网：https://www.alientek.com")
                font.pixelSize: 20 * scaleFfactor
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                anchors.bottom: flickable.top
                color: "#4169e1"
            }
            Flickable {
                id: flickable
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 80 * scaleFfactor
                anchors.top: parent.top
                anchors.topMargin: 50  * scaleFfactor
                clip: true
                contentHeight: instructionsFileReadText.contentHeight + 10
                ScrollBar.vertical: ScrollBar {
                    id: scrollBar
                    width: scaleFfactor * 8
                    opacity: 1.0
                    onActiveChanged: {
                        active = true;
                    }
                    Component.onCompleted: {
                        scrollBar.active = true;
                    }
                    contentItem: Rectangle{
                        implicitWidth: scaleFfactor * 6
                        implicitHeight: scaleFfactor * 100
                        radius: scaleFfactor * 2
                        color: scrollBar.hovered ? "#88101010" : "#33101010"
                    }
                }

                Text {
                    id: instructionsFileReadText
                    anchors.fill: parent
                    anchors.margins: 20
                    text: qsTr(instructionsFileRead.instructionsContent)
                    font.pixelSize: 15 * scaleFfactor
                    lineHeight: 25 * scaleFfactor
                    wrapMode: Text.WrapAnywhere
                    lineHeightMode: Text.FixedHeight
                }
            }
        }
    }

    InstructionsFileRead {
        id: instructionsFileRead
    }

    MemoryWatcher {
        id: memoryWatcher
        running: main_swipeView.currentIndex === 2
    }
}
