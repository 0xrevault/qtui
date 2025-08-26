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

    Image {
        id: wallpaper
        x: 0
        y: 0
        height: parent.height
        width: parent.width
        opacity: 1 - Math.abs(wallpaper.y) / wallpaper.height
        fillMode: Image.PreserveAspectCrop
        smooth: true
        source: "file://" + appCurrtentDir + "/src/ipad/ipad/ipad.jpg"
        Behavior on y {
            PropertyAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
        onYChanged: {
            if (Math.abs(wallpaper.y) == wallpaper.height) {
                window.flags = Qt.FramelessWindowHint | Qt.WindowTransparentForInput;
                systemUICommonApiClient.askSystemUItohideOrShow(SystemUICommonApiClient.Show);
                window.hide();
                lockText.opacity = 1.0;
            }
        }
        MouseArea {
            anchors.fill: parent
            drag.target: wallpaper
            drag.maximumX: 0
            drag.minimumX: 0
            drag.minimumY: -wallpaper.height
            drag.maximumY: 0
            onReleased: {
                if (wallpaper.y <= -wallpaper.height / 3)
                    wallpaper.y = -wallpaper.height;
                else
                    wallpaper.y = 0;
            }
        }
        Text {
            id: lockText
            opacity: 1 - Math.abs(wallpaper.y) / wallpaper.height
            y: parent.height - 50 * scaleFacter - opacity * 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("向上轻扫以解锁")
            color: "white"
            font.pixelSize: 25 * scaleFacter
            // Remove opacity animation to avoid continuous updates/flicker
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
        }

        Text {
            id: date
            anchors.top: time.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            text: systemTime.system_date2 + " " + systemTime.system_week
            color: "white"
            font.pixelSize: 30 * scaleFacter
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
