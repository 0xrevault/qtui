/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   desktop
* @brief         PlayList.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com
* @link          www.openedv.com
* @date          2021-09-13
*******************************************************************/
import QtQuick.Controls 2.12
import QtQuick 2.0
import QtMultimedia 5.0
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0

Item {
    id: root
    property int music_currentIndex: -1
    property int musicCount: 0
    property string musicName

    onMusic_currentIndexChanged: {
        music_listView.currentIndex = music_currentIndex
    }

    Item {
        anchors.top: parent.top
        anchors.topMargin: 25 * scaleFactor
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -10 * scaleFactor
        //color: "#88101010"
        //radius: 20

        Item {
            width: 80 * scaleFactor
            height: 50 * scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 40 * scaleFactor
            anchors.bottom: music_listView.top
            Text {
                text: qsTr("播放列表")
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 25 * scaleFactor
                color: "white"
            }
        }
        ListView {
            id: music_listView
            visible: true
            anchors.fill: parent
            currentIndex: 0
            clip: true
            spacing: 10
            onFlickStarted: scrollBar.opacity = 1.0
            onFlickEnded: scrollBar.opacity = 0.0

            onCountChanged: {
                musicCount = music_listView.count
            }
            /*header: Item {
                width: 80
                height: 50
                Text {
                    text: qsTr("播放列表")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 25 * scaleFactor
                    color: "white"
                }
            }*/

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                width: 10
                opacity: 0.0
                onActiveChanged: {
                    active = true;
                }
                Component.onCompleted: {
                    scrollBar.active = true;
                }
                contentItem: Rectangle{
                    implicitWidth: 6
                    implicitHeight: 100
                    radius: 2
                    color: scrollBar.hovered ? "#88101010" : "#30101010"
                }
                Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
            }

            model: music_playlistModel
            delegate: Item {
                id: itembg
                width: parent.width - 10 * scaleFactor
                //height: music_listView.currentIndex === index && musicPlayer.playbackState === MediaPlayer.PlayingState ? 80 : 60
                height: 60 * scaleFactor
                Rectangle {
                    height: parent.height
                    anchors.right: parent.right
                    anchors.left: ablum_item.left
                    radius: 5 * scaleFactor
                    color: music_listView.currentIndex === index && musicPlayer.playbackState
                           === MediaPlayer.PlayingState ? "#55101010" : "transparent"
                }
                Text {
                    visible: false
                    id: listIndex
                    text: index < 10 ? "0" + (index + 1) : index + 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 25 * scaleFactor
                    font.pixelSize: 25 * scaleFactor
                    color: "white"
                }

                Item {
                    id: ablum_item
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 40 * scaleFactor
                    width: itembg.height
                    height: itembg.height
                    Image {
                        anchors.fill: parent
                        id: album
                        visible: false
                        source: "file://" + appCurrtentDir + "/resource/artist/" + music_playlistModel.getSongName(index)
                    }
                    Rectangle {
                        anchors.fill: album
                        id: album_opacityMask_rect
                        radius: 5 * scaleFactor
                        visible: false
                    }
                    OpacityMask {
                        anchors.fill: album
                        source: album
                        cached: true
                        maskSource: album_opacityMask_rect
                        visible: true
                    }
                }
                Rectangle {
                    height: 1
                    anchors.left: column.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: "#33ffffff"
                }
                Column {
                    id: column
                    anchors.left: ablum_item.right
                    anchors.leftMargin: 20 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: songsname
                        // width: itembg.width - 220
                        // anchors.verticalCenter: parent.verticalCenter
                        // anchors.left: ablum_item.right
                        // verticalAlignment: Text.AlignVCenter
                        text: title
                        elide: Text.ElideRight
                        anchors.leftMargin: 10 * scaleFactor
                        color: parent.ListView.isCurrentItem && musicPlayer.playbackState === MediaPlayer.PlayingState ? "white" : "#D0D0D0"
                        font.pixelSize: 25 * scaleFactor
                        font.bold: parent.ListView.isCurrentItem && musicPlayer.playbackState === MediaPlayer.PlayingState
                    }

                    Text {
                        id: songsauthor
                        visible: true
                        width: 200 * scaleFactor
                        height: 15 * scaleFactor
                        // anchors.bottom: parent.bottom
                        // anchors.left: ablum_item.right
                        // verticalAlignment: Text.AlignVCenter
                        text: author
                        //anchors.leftMargin: 10
                        elide: Text.ElideRight
                        color: parent.ListView.isCurrentItem && musicPlayer.playbackState === MediaPlayer.PlayingState ? "white" : "#D0D0D0"
                        font.pixelSize: 15 * scaleFactor
                        font.bold: parent.ListView.isCurrentItem
                    }
                }

                MouseArea {
                    id: mouserArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        music_playlistModel.currentIndex = index
                        music_listView.currentIndex = index
                        musicLayout.playBtnSignal()
                        musicPlayer.play()
                    }
                }

                Button {
                    id: itembtn
                    visible: false
                    anchors.right: parent.right
                    anchors.verticalCenter: itembg.verticalCenter
                    width: itembg.height
                    height: itembg.height
                    onClicked: {
                        music_playlistModel.currentIndex = index
                        music_listView.currentIndex = index
                        if (musicPlayer.playbackState !== MediaPlayer.PlayingState)
                            musicPlayer.play()
                    }
                    background: Rectangle {
                        width: Control.width
                        height: Control.height
                        radius: 3
                        color: Qt.rgba(0,0,0,0)
                        Image {
                            id: itemImage
                            width: 40 * scaleFactor
                            height: 40 * scaleFactor
                            anchors.centerIn: parent
                            source:  music_listView.currentIndex !== index || musicPlayer.playbackState !== MediaPlayer.PlayingState
                                     ? "qrc:/icons/btn_play.png" : "qrc:/icons/btn_pause.png"
                            opacity: 0.8
                        }
                    }
                }
            }
        }
    }
}
