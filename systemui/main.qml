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
    id: window
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true
    property real scaleFfactor: window.width / 720
    flags: Qt.FramelessWindowHint
    x: 0
    y: 0

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
            "按键": qsTr("按键")
        };
        return translations[text] || text;
    }

    SystemUICommonApiServer {
        id: systemUICommonApiServer
        onAppAsktoHideOrShow: function (action) {
            if (action === SystemUICommonApiServer.Hide) {
                // Keep overlay visible across apps: don't hide window; make it pass-through
                desktop.visible = false;
                window.flags = Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput;
                window.show();
            }
            if (action === SystemUICommonApiServer.Show) {
                desktop.visible = true;
                phonebg_scale.xScale = 1.0;
                window.flags = Qt.FramelessWindowHint;
                window.show();
                window.requestActivate();
                systemUICommonApiServer.currtentLauchAppName = "";
            }
        }
        onCurrtentLauchAppNameChanged: {
            if (systemUICommonApiServer.currtentLauchAppName === "null")
                systemUICommonApiServer.appAsktoHideOrShow(SystemUICommonApiServer.Show);
        }
    }

    function launchActivity(name, x, y, item, iconPath, currtentPage, launchMode) {
        window.flags = Qt.FramelessWindowHint | Qt.WindowTransparentForInput;
        systemUICommonApiServer.launchProperties(x, y, item.width, item.height, iconPath, currtentPage, launchMode);
        systemUICommonApiServer.launchApp(name);
    }

    Item {
        id: desktop
        anchors.fill: parent
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
                    Behavior on xScale {
                        PropertyAnimation {
                            duration: 50/*350*/
                            easing.type: Easing.Linear
                        }
                    }
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
                // Removed explain button/timer; keep a simple page indicator
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
                    Component {
                        id: indicator_delegate
                        Rectangle {
                            opacity: 1
                            width: scaleFfactor * 8
                            height: scaleFfactor * 8
                            radius: width / 2
                            color: main_swipeView.currentIndex === index ? "#ffffff" : "#808080"
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
    }

    InstructionsFileRead {
        id: instructionsFileRead
    }

    MemoryWatcher {
        id: memoryWatcher
        running: true
    }

    // Performance overlay - fixed at top-left
    Rectangle {
        id: perfOverlay
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 10
        color: "#88101010"
        radius: 6
        border.color: "#33ffffff"
        border.width: 1
        z: 1000
        width: perfText.paintedWidth + 16
        height: perfText.paintedHeight + 16
        Text {
            id: perfText
            text: memoryWatcher.overlayText
            color: "white"
            font.family: "monospace"
            font.pixelSize: 12 * scaleFfactor
            wrapMode: Text.Wrap
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 8
        }
    }
}
