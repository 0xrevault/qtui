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
import com.alientek.qmlcomponents 1.0

Window {
    id: window
    visible: true
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    x: 0
    y: 0
    color: "black"
    flags: Qt.FramelessWindowHint
    property real scaleFacter: window.width / 1024

    SystemTime {
        id: systemTime
    }

    Flickable {
        id: flk
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: height * 2
        contentY: 0
        pressDelay: 0
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        maximumFlickVelocity: 9000
        flickDeceleration: 3600
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: contentRoot
            width: flk.width
            height: flk.contentHeight

            Image {
                id: wallpaper
                anchors.top: parent.top
                width: flk.width
                height: flk.height
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
                sourceSize.width: width
                sourceSize.height: height
                source: "file://" + appCurrtentDir + "/src/ipad/ipad/ipad.jpg"
            }

            // 占位以便内容可上滑到整屏高度
            Item {
                anchors.top: wallpaper.bottom
                width: 1
                height: flk.height
            }

            Text {
                id: lockText
                opacity: 1 - flk.contentY / flk.height
                y: wallpaper.height - 50 * scaleFacter - opacity * 10
                anchors.horizontalCenter: wallpaper.horizontalCenter
                text: qsTr("向上轻扫以解锁")
                color: "white"
                font.pixelSize: 25 * scaleFacter
                renderType: Text.NativeRendering
            }

            Dock {}

            Text {
                id: time
                anchors.top: wallpaper.top
                anchors.horizontalCenter: wallpaper.horizontalCenter
                anchors.topMargin: 50 * scaleFacter
                text: systemTime.system_time
                color: "white"
                font.pixelSize: 80 * scaleFacter
                renderType: Text.NativeRendering
            }

            Text {
                id: date
                anchors.top: time.bottom
                anchors.horizontalCenter: wallpaper.horizontalCenter
                anchors.topMargin: 10
                text: systemTime.system_date2 + " " + systemTime.system_week
                color: "white"
                font.pixelSize: 30 * scaleFacter
                renderType: Text.NativeRendering
            }
        }

        onMovementEnded: {
            if (contentY >= flk.height / 3) {
                contentY = flk.height;
                window.flags = Qt.FramelessWindowHint | Qt.WindowTransparentForInput;
                systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Show);
                window.hide();
            } else {
                contentY = 0;
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
                wallpaper.y = 0;
                systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Hide);
            }
            if (cmd === SystemUICommonApiClient.Quit)
                Qt.quit();
        }
    }
}
