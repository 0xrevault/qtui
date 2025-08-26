/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         Page1.qml
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
    id: page1
    // Do not anchor root to parent; allow SwipeView to position pages by x
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    layer.enabled: true
    layer.smooth: true
    ApkListModel {
        id: apkListModel
        Component.onCompleted: apkListModel.add(appCurrtentDir + "/src/" + hostName + "/apk1.cfg")
    }

    ColumnLayout {
        id: columnLayout2
        width: control_item.width
        height: control_item.height / 3 * 2
        anchors.top: parent.top
        anchors.topMargin: 30
        GridView {
            id: item_gridView
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            width: control_item.width - control_item.width / 13
            height: control_item.width / 4 * 3  // three column
            visible: true
            interactive: false
            clip: true
            snapMode: ListView.SnapOneItem
            cellWidth: item_gridView.width / 4
            cellHeight: cellWidth * 1.3
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
                width: window.width / 8
                height: width
                source: apkIconPath
                asynchronous: true
                cache: true
                sourceSize.width: width
                sourceSize.height: height

                visible: systemUICommonApiServer.currtentLauchAppName !== programName
            }

            Image {
                id: appIcon2
                anchors.centerIn: parent
                width: appIcon.width
                height: width
                source: apkIconPath
                asynchronous: true
                cache: true
                sourceSize.width: width
                sourceSize.height: height

                visible: systemUICommonApiServer.coldLaunch
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: window.width / 720 * 18
                anchors.horizontalCenter: parent.horizontalCenter
                text: translateText(apkName)
                color: "white"
                font.pixelSize: window.width / 720 * 22
                font.bold: true
            }

            Loader {
                id: pressedFx
                anchors.fill: appIcon2
                active: appButton.pressed
                sourceComponent: Colorize {
                    anchors.fill: appIcon2
                    source: appIcon2
                    saturation: 0.0
                    lightness: -1.0
                    opacity: 0.2
                    cached: true
                }
            }
        }
    }
}
