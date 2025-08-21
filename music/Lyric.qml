/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   desktop
* @brief         Lyric.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com
* @link          www.openedv.com
* @date          2021-09-13
*******************************************************************/

import QtQuick 2.0
import QtQuick.Controls 2.5
import QtMultimedia 5.0

Item {
    id: lyric_item
    Connections {
        target: music_lyricModel
        function onCurrentIndexChanged() {
            music_lyric.currentIndex = music_lyricModel.currentIndex
        }
    }

    GridView {
        anchors.fill: parent
        id: music_lyric
        clip: false
        cellWidth: parent.width
        cellHeight: 40 * scaleFactor
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: 0
        preferredHighlightEnd: 50
        highlight: Rectangle {
            color: Qt.rgba(0, 0, 0, 0)
            Behavior on y {
                SmoothedAnimation {
                    duration: 300
                }
            }
        }
        model: music_lyricModel
        delegate: Rectangle {
            width: lyric_item.width
            height: 40 * scaleFactor
            color: Qt.rgba(0,0,0,0)
            Text {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "   " + textLine
                color: parent.GridView.isCurrentItem ? "white" : "#eedddddd"
                font.pixelSize: parent.GridView.isCurrentItem ? 30 * scaleFactor : 25 * scaleFactor
                Behavior on font.pixelSize { PropertyAnimation { duration: 200; easing.type: Easing.Linear } }
                font.bold: parent.GridView.isCurrentItem
            }
        }
    }
}
