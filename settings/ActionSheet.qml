/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ActionSheet.qml: 上拉菜单
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-01
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12

Item {
    property bool opened: false
    id: sheet
    width: parent.width
    height: parent.height
    MouseArea { anchors.fill: parent }
    x: 0
    y: height
    Behavior on y { PropertyAnimation { duration: 250; easing.type: Easing.OutQuad } }

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: 0
        drag.maximumY: parent.height
        property int dragY
        onPressed: {
            dragY = parent.y
        }
        onReleased: {
            if (parent.y - dragY >= 100)
                sheet.close()
            else
                sheet.open()
        }
    }

    function open() {
        opened = true
        actionSheet.visible = true
        //app_qwifi.inputPanelReadyOpen()
        sheet.y = 0
        //wifi.setModal(true)
    }

    function close() {
        opened = false
        //app_qwifi.inputPanelReadyClose()
        sheet.y = height
    }
}

