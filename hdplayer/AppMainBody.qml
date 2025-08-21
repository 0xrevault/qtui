/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         AppMainBody.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-04-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.15
import com.alientek.qmlcomponents 1.0
Item {
    anchors.fill: parent
    property int control_duration: 0
    property QtObject mediaModel

    onVisibleChanged:  {
        if (visible)
            control_duration = 0
    }

    Loader {
        active: true
        asynchronous: false // do not set true
        id: loader
        anchors.fill: parent
        source: "PlayerLayout.qml"
    }

    // AMediaList {
    //     id: mediaModel
    //     currentIndex: -1
    //     onCurrentIndexChanged: {
    //     }
    // }

    // Component.onCompleted: {
    //     mediaModel.add(appCurrtentDir +  "/resource/media/movies")
    // }
}
