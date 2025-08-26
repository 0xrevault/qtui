/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         main.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-11
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0

Window {
    id: window
    visible: true
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    x: 0
    y: 0
    color: "transparent"
    flags: Qt.FramelessWindowHint
    property real scaleFacter: window.width / 1024

    SystemTime {
        id: systemTime
    }

    // Lock background fixed as a top cover; height shrinks with drag to reveal desktop
    Item {
        id: lockCover
        anchors.top: parent.top
        width: parent.width
        height: Math.max(0, parent.height - flk.contentY)
        clip: true
        z: 0
        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: false
            cache: true
            sourceSize.width: width
            sourceSize.height: height
            source: "file://" + appCurrtentDir + "/src/ipad/ipad/lockscreen.png"
        }
    }

    Flickable {
        id: flk
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: height * 2
        contentY: 0
        property bool unlocked: false
        pressDelay: 0
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        maximumFlickVelocity: 9000
        flickDeceleration: 3600
        boundsBehavior: Flickable.StopAtBounds
        z: 1

        Item {
            id: contentRoot
            width: flk.width
            height: flk.contentHeight

            // 占位以便内容可上滑到整屏高度
            Item {
                anchors.top: parent.top
                width: 1
                height: flk.height
            }

            Text {
                id: lockText
                opacity: 1 - flk.contentY / flk.height
                y: flk.height - 50 * scaleFacter - opacity * 10
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("向上轻扫以解锁")
                color: "white"
                font.pixelSize: 25 * scaleFacter
                renderType: Text.NativeRendering
            }

            Dock {}

            Text {
                id: time
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 50 * scaleFacter
                text: systemTime.system_time
                color: "white"
                font.pixelSize: 80 * scaleFacter
                renderType: Text.NativeRendering
            }

            Text {
                id: date
                anchors.top: time.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 10
                text: systemTime.system_date2 + " " + systemTime.system_week
                color: "white"
                font.pixelSize: 30 * scaleFacter
                renderType: Text.NativeRendering
            }
        }

        onContentYChanged: {
            if (!flk.unlocked && contentY >= flk.height / 2) {
                flk.unlocked = true;
                window.flags = Qt.FramelessWindowHint | Qt.WindowTransparentForInput;
                systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Show);
                window.hide();
            }
        }
        onMovementEnded: {
            if (!flk.unlocked) {
                contentY = contentY >= flk.height / 2 ? flk.height : 0;
            }
        }
    }

    SystemUICommonApiClient {
        id: systemUICommonApiClient
        appName: "lockscreenservice"
        onActionCommand: {
            if (cmd === SystemUICommonApiClient.Show) {
                window.flags = Qt.FramelessWindowHint;
                window.show();
                window.requestActivate();
                flk.contentY = 0;
                flk.unlocked = false;
                systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Hide);
            }
            if (cmd === SystemUICommonApiClient.Quit)
                Qt.quit();
        }
    }
}
