/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         Client.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-10
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.0
import com.alientek.qmlcomponents 1.0
import QtQuick.Controls 2.12

Item {
    id: client
    property real scaleFactor: client.width / 1024
    property string programmerName
    anchors.fill: parent
    SystemUICommonApiClient {
        id: systemUICommonApiClient
        appName: programmerName
        onActionCommand: {
            if (cmd === SystemUICommonApiClient.Show) {
                if (programmerName != "cube")
                    window.flags = Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint;
                // 延迟显示内容，避免冷启动白屏：先显示窗口但隐藏内容，稍后再显示并隐藏桌面
                appMainBody.visible = false;
                window.show();
                window.requestActivate();
                delayToShowTimer.start();
            }
            if (cmd === SystemUICommonApiClient.Quit)
                Qt.quit();
        }
    }

    Timer {
        id: delayToShowTimer
        interval: window.width > 1280 ? 60 : 120
        repeat: false
        running: false
        onTriggered: {
            appMainBody.visible = true;
            enterAnim.restart();
            systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Hide);
            window.requestActivate();
        }
    }

    AppMainBody {
        id: appMainBody
        anchors.fill: parent
        visible: true
    }

    Timer {
        id: delayToQuitTimer
        repeat: false
        running: false
        interval: 200
        onTriggered: Qt.quit()
    }

    NumberAnimation {
        id: enterAnim
        target: appMainBody
        property: "scale"
        from: 0.94
        to: 1.0
        duration: 180
        easing.type: Easing.OutCubic
        running: false
    }

    RoundButton {
        id: backBtn
        visible: true
        x: parent.x + parent.width - 100 * scaleFactor
        y: parent.y + parent.height / 2 - 100 * scaleFactor
        width: 100 * scaleFactor
        height: width
        hoverEnabled: enabled
        opacity: mouseArea.pressed ? 1.0 : 0.5
        background: Rectangle {
            color: "#88101010"
            radius: parent.width / 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: 90 * scaleFactor
            height: width
            color: "#88ffffff"
            radius: parent.width / 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: 80 * scaleFactor
            height: width
            color: "#aaffffff"
            radius: parent.width / 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: 70 * scaleFactor
            height: width
            color: "#ffffff"
            radius: parent.width / 2
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag.target: backBtn
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: client.width - 100 * scaleFactor
            drag.maximumY: client.height - 100 * scaleFactor
            onClicked: {
                window.flags = Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowStaysOnTopHint;
                if (!systemUICommonApiClient.backgroundTask) {
                    // slide-up then quit
                    exitAnim.restart();
                    systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Show);
                    delayToQuitTimer.start();
                } else {
                    systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Show);
                    appMainBody.visible = false;
                    window.hide();
                }
            }

            onPressAndHold: {
                systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Show);
                delayToQuitTimer.start();
            }
        }
    }
    NumberAnimation {
        id: exitAnim
        target: appMainBody
        property: "y"
        from: 0
        to: -client.height * 0.04
        duration: 150
        easing.type: Easing.InCubic
        running: false
        onStopped: {
            appMainBody.y = 0;
        }
    }
    Component.onCompleted: systemUICommonApiClient.onSystemuiconfChanged()
}
