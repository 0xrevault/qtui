/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         BottomApp.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-07
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.12
import com.alientek.qmlcomponents 1.0

Item {
    visible: main_swipeView.currentIndex !== 0
    anchors.fill: parent
    ApkListModel {
        id: apkListModel
        Component.onCompleted: apkListModel.add(appCurrtentDir + "/src/" + hostName + "/apk3.cfg")
    }
    Loader {
        id: fuzzPanelLoader
        active: false
        sourceComponent: FuzzPanel {
            id: fuzzPanel
            anchors.centerIn: bottom_appItem_parent
            width: bottom_appItem_parent.width
            height: bottom_appItem_parent.height
            target: phonebg
            visible: true
        }
    }

    Rectangle {
        id: bottom_app_rect_mask
        clip: true
        anchors.fill: bottom_appItem_parent
        radius: bottom_appItem_parent.height / 3
        color: "black"
        visible: false
    }

    Loader {
        id: maskLoader
        active: fuzzPanelLoader.active
        sourceComponent: OpacityMask {
            anchors.fill: fuzzPanel
            source: fuzzPanel
            maskSource: bottom_app_rect_mask
        }
    }

    Rectangle {
        id: bottom_app_rect
        clip: true
        anchors.fill: bottom_appItem_parent
        radius: bottom_appItem_parent.height / 3
        color: "#55f0f0f0"
        visible: true
    }

    Item {
        id: bottom_appItem_parent
        width: item_listView.contentWidth
        height: control_item.width / 8 * 1.2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10

        ListView {
            id: item_listView
            visible: true
            anchors.centerIn: parent
            height: control_item.width / 8 * 1.5
            width: item_listView.contentWidth
            interactive: false
            orientation: ListView.Horizontal
            currentIndex: -1
            clip: true
            snapMode: ListView.SnapOneItem
            model: apkListModel
            delegate: item_listView_delegate
            spacing: 0
        }
    }

    Component {
        id: item_listView_delegate
        Button {
            id: appButton
            width: control_item.width / 6
            height: width
            enabled: installed
            onClicked: {
                launchActivity(programName, mapToGlobal(appIcon.x, appIcon.y).x, mapToGlobal(appIcon.x, appIcon.y).y, appIcon, apkIconPath, main_swipeView.currentIndex, SystemUICommonApiServer.ClickIcon);
            }
            background: Image {
                id: appIcon
                anchors.centerIn: parent
                width: control_item.width / 8
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

            Loader {
                id: pressedFx
                anchors.fill: appIcon2
                active: appButton.pressed
                sourceComponent: Colorize {
                    // Fill the Loader itself; appIcon2 is not a sibling here
                    anchors.fill: parent
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
