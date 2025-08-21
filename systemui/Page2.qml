/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         Page2.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-07
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0

Item {
    id: page2
    ApkListModel {
        id: apkListModel
        Component.onCompleted: apkListModel.add(appCurrtentDir + "/src/" + hostName + "/apk2.cfg")
    }

    ColumnLayout {
        width: control_item.width
        height: control_item.height - control_item.width / 14.4
        anchors.top: parent.top
        anchors.topMargin: 30
        GridView {
            id: item_gridView
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            width: control_item.width - control_item.width / 13
            height: control_item.width / 4 * 5  // three column
            visible: true
            interactive: false
            clip: false
            snapMode: ListView.SnapOneItem
            cellWidth: item_gridView.width / 6
            cellHeight: cellWidth * 1.2
            model: apkListModel
            delegate: item_gridView_delegate
        }
    }

    Component {
        id: item_gridView_delegate
        Button {
            id: appButton
            width: item_gridView.cellWidth
            height: item_gridView.cellHeight
            enabled: installed
            onClicked: {
                launchActivity(programName, mapToGlobal(appIcon.x, appIcon.y).x, mapToGlobal(appIcon.x, appIcon.y).y, appIcon, apkIconPath, main_swipeView.currentIndex, SystemUICommonApiServer.ClickIcon);
            }

            background: Image {
                id: appIcon
                anchors.centerIn: parent
                width: window.width / 12
                height: width
                source: apkIconPath
                visible: systemUICommonApiServer.currtentLauchAppName !== programName
            }

            Image {
                id: appIcon2
                anchors.centerIn: parent
                width: appIcon.width
                height: width
                source: apkIconPath
                visible: systemUICommonApiServer.coldLaunch
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: window.width / 720 * 15
                anchors.horizontalCenter: parent.horizontalCenter
                text: translateText(apkName)
                color: "white"
                font.pixelSize: window.width / 720 * 15
                font.bold: true
            }

            Colorize {
                id: colorize1
                anchors.fill: appIcon2
                source: appIcon2
                saturation: 0.0
                lightness: -1.0
                opacity: 0.2
                cached: true
                visible: appButton.pressed
            }
        }
    }

    Rectangle {
        width: 160 * scaleFfactor
        height: 90 * scaleFfactor
        radius: 12 * scaleFfactor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 50 * scaleFfactor
        color: mouseArea.pressed ? "#DD101010" : "#88101010"

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: memoryWatcher.clearCache()
        }
        Text {
            color: "white"
            text: qsTr("内存")
            font.pixelSize: scaleFfactor * 15
            font.bold: true
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
        }
        Text {
            id: txt_progress
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 22 * scaleFfactor
            font.bold: true
            font.family: "monospace"
            text: Math.round(memoryWatcher.memoryUsedPercent) + "%"
            color: memoryWatcher.memoryUsedPercent <= 60 ? "#1afa29" : (memoryWatcher.memoryUsedPercent <= 70 ? "#ff6d00" : "#E3170D")
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
