/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         PhotoViewLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2023-02-24
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.0
import com.alientek.qmlcomponents 1.0
import QtQuick.Controls 2.12
Item {
    id: photoViewLayout
    anchors.fill: parent
    property int m_highlightMoveDuration: 0
    property QtObject photoListModel
    property real scaleFfactor: window.width / 720
    signal photoPropertyChanged()
    signal deleteButtonClicked()


    PhotoListModel {
        id: photoListModel
        currentIndex: -1
        albumPath: appCurrtentDir + "/resource/images/"
    }

    Rectangle {
        anchors.fill: parent
        color: "white"
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: false
        PhotoListView {
            id: phtoListView
        }
        DisplayPhoto {
            clip: true
            id: displayPhoto
        }
    }
}
