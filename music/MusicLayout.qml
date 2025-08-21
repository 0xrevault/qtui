/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   music
* @brief         MusicLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-05-04
*******************************************************************/
import QtQuick 2.12
import QtMultimedia 5.0
import QtQuick.Controls 2.5
import com.alientek.qmlcomponents 1.0
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
Item {
    id: musicLayout
    anchors.fill: parent
    property int lyric_CurrtentIndex: -1
    property int control_duration: 0
    signal playBtnSignal()
    signal previousBtnSignal()
    signal nextBtnSignal()
    signal playProgressChanged(real playProgress)
    property int progress_maximumValue: 0
    property bool progress_pressed: false
    property int progress_value: 0
    property int music_loopMode: 2
    property real scaleFactor: musicLayout.width / 1024
    property bool appActive: appMainBody.visible

    function songsInit(){
        music_playlistModel.add(appCurrtentDir)
    }

    Connections {
        target: musicPlayer
        function onSourceChanged() {
            music_lyricModel.setPathofSong(musicPlayer.source, appCurrtentDir);
        }
    }
    LyricModel {
        id: music_lyricModel
    }

    PlayListModel {
        id: music_playlistModel
        currentIndex: 0
        onCurrentIndexChanged: {
            musicPlayer.source = getcurrentPath()
            musicPlayer.play() // ???
        }

        onSongNameChanged: {
            music_lyricModel.setPathofSong(music_playlistModel.songName, appCurrtentDir)
        }
        Component.onCompleted: {
            songsInit()
        }
    }


    function currentMusicTime(time){
        var sec = Math.floor(time / 1000);
        var hours = Math.floor(sec / 3600);
        var minutes = Math.floor((sec - hours * 3600) / 60);
        var seconds = sec - hours * 3600 - minutes * 60;
        var hh, mm, ss;
        if(hours.toString().length < 2)
            hh = "0" + hours.toString();
        else
            hh = hours.toString();
        if(minutes.toString().length < 2)
            mm="0" + minutes.toString();
        else
            mm = minutes.toString();
        if(seconds.toString().length < 2)
            ss = "0" + seconds.toString();
        else
            ss = seconds.toString();
        return /*hh+":"*/ + mm + ":" + ss
    }

    onPlayBtnSignal: {
        if (playList.musicCount === 0)
            return
        if (music_playlistModel.currentIndex !== -1) {
            musicPlayer.source =  music_playlistModel.getcurrentPath()
            playList.music_currentIndex = music_playlistModel.currentIndex
            playList.musicName = music_playlistModel.getcurrentSongName()
            musicPlayer.playbackState === MediaPlayer.PlayingState ? musicPlayer.pause() : musicPlayer.play()
        }
    }

    onPreviousBtnSignal: {
        switch (music_loopMode) {
        case 0:
        case 1:
        case 2:
            music_playlistModel.currentIndex--
            musicPlayer.play()
            break;
        case 3:
            music_playlistModel.randomIndex();
            musicPlayer.play()
            break;
        }
    }

    onNextBtnSignal: {
        if (music_playlistModel.count !== 0)
            switch (music_loopMode) {
            case 0:
            case 1:
            case 2:
                music_playlistModel.currentIndex++
                musicPlayer.play()
                break;
            case 3:
                music_playlistModel.randomIndex()
                musicPlayer.play()
                break;
            }
    }


    Connections {
        target: musicPlayer
        function onPositionChanged() {
            progress_maximumValue = musicPlayer.duration
            if(!progress_pressed) {
                progress_value = musicPlayer.position
                playProgressChanged(musicPlayer.position / musicPlayer.duration)
            }
        }
        function onPlaybackStateChanged() {
            switch (musicPlayer.playbackState) {
            case MediaPlayer.PlayingState:
                break;
            case MediaPlayer.PausedState:
            case MediaPlayer.StoppedState:
                break;
            default:
                break;
            }
        }
        function onStatusChanged() {
            switch (musicPlayer.status) {
            case MediaPlayer.NoMediaMedia:
                break;
            case MediaPlayer.LoadingMedia:
                break;
            case MediaPlayer.LoadedMedia:
                progress_maximumValue = musicPlayer.duration
                break;
            case MediaPlayer.BufferingMedia:
                break;
            case MediaPlayer.StalledMedia:
                break;
            case MediaPlayer.BufferedMedia:
                break;
            case MediaPlayer.InvalidMediaMedia:
                switch (musicPlayer.error) {
                case MediaPlayer.FormatError:
                    ttitle.text = qsTr("需要安装解码器");
                    break;
                case MediaPlayer.ResourceError:
                    ttitle.text = qsTr("文件错误");
                    break;
                case MediaPlayer.NetworkError:
                    ttitle.text = qsTr("网络错误");
                    break;
                case MediaPlayer.AccessDenied:
                    ttitle.text = qsTr("权限不足");
                    break;
                case MediaPlayer.ServiceMissing:
                    ttitle.text = qsTr("无法启用多媒体服务");
                    break;
                }
                break;
            case MediaPlayer.EndOfMedia:
                musicPlayer.autoPlay = true
                music_lyricModel.currentIndex = 0
                progress_maximumValue = 0
                progress_value = 0
                switch (music_loopMode) {
                case 1:
                    musicPlayer.play()
                    break;
                case 2:
                    music_playlistModel.currentIndex++
                    break;
                case 3:
                    music_playlistModel.randomIndex()
                    break;
                default:
                    break;
                }
                break;
            }
        }
    }
    Connections {
        target: music_playlistModel
        function onCurrentIndexChanged() {
            playList.music_currentIndex = music_playlistModel.currentIndex
            playList.musicName = music_playlistModel.songName
        }
    }

    Connections {
        target: playList
        function onMusicNameChanged() {
            music_lyricModel.setPathofSong(playList.musicName, appCurrtentDir)
            artBg.source = "file://" + appCurrtentDir + "/resource/artist/" + playList.musicName + ".jpg"
        }
    }

    RowLayout {
        z: 10
        anchors.fill: parent
        spacing: 25

        Item {
            Layout.leftMargin: 50
            width: window.height / 1.5
            height: width
            Image {
                id: art_album
                anchors.fill: parent
                source: artBg.source
                visible: false
            }

            Rectangle {
                anchors.fill: art_album
                id: art_album_opacityMask
                visible: false
                radius: 10 * scaleFactor
            }

            OpacityMask {
                anchors.fill: art_album
                source: art_album
                maskSource: art_album_opacityMask
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 50
            Layout.fillWidth: true
            height: art_album.height +  art_album.height / 6
            PlayPanel {id: playPanel}
            PlayList {
                id: playList
                visible: !playPanel.visible
                anchors.centerIn: parent
                width: parent.width
                height: parent.height + 25
            }
        }
    }

    Image {
        id: artBg
        width: window.width
        height: window.height
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: musicPlayer.hasAudio ?
                    "file://" + appCurrtentDir + "/resource/artist/" + playList.musicName +".jpg" : "qrc:/images/default.jpg"

        onSourceChanged: {
            if (!music_playlistModel.checkTheAlbumImageIsExists(artBg.source))
                artBg.source = "qrc:/images/default.jpg"
        }
    }

    AudioSpectrumAnalyzer {
        id: audioSpectrumAnalyzer
        onBarValueChanged: {
            if (!visible)
                return
            fastBlur.radius = 80 + 40 * value
            fastBlur.scale = 1 + 0.1 * value
            //console.log(value)
        }
    }

    Connections {
        target: musicPlayer
        function onSourceChanged()  {
            audioSpectrumAnalyzer.reset()
        }
    }

    Timer{
        id: myTimer
        running: true
        interval: 2000
        repeat: false
        onTriggered: {
            audioSpectrumAnalyzer.setMediaPlayer(myplayer)
            // releaseResources
            myTimer.destroy()
        }
    }

    FastBlur {
        id: fastBlur
        anchors.fill: artBg
        source: artBg
        radius: 100
        // Rectangle {
        //     opacity: 0.3
        //     color: "black"
        //     anchors.fill: parent
        // }
    }

    Button {
        id: playListBt
        z: 11
        width: 64 * scaleFactor
        height: width
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        opacity: playListBt.pressed ? 0.5 : 1.0
        checkable: true
        checked: false
        background: Rectangle {
            width: 50 * scaleFactor
            height: width
            radius: 10
            color: playListBt.checked ? "#94a2c6" : "transparent"
            Image {
                source: "qrc:/icons/btn_playlist.png"
                width: 30 * scaleFactor
                height: width
                anchors.centerIn: parent
            }
        }
        onCheckedChanged: {
            playPanel.visible = !playListBt.checked
        }
    }

    Button {
        id: effectstBt
        z: 11
        width: 64 * scaleFactor
        height: width
        anchors.right: playListBt.left
        anchors.rightMargin: 30
        anchors.verticalCenter: playListBt.verticalCenter
        opacity: effectstBt.pressed ? 0.5 : 1.0
        checkable: true
        checked: false
        background: Item {
            width: 50 * scaleFactor
            height: width
            Image {
                source: effectstBt.checked ? "qrc:/icons/effects_checked.png" : "qrc:/icons/effects_unchecked.png"
                width: 50 * scaleFactor
                height: width
                anchors.centerIn: parent
            }
        }
        onCheckedChanged: {
            audioSpectrumAnalyzer.enableSpecialEffects(checked)
        }
    }

    Button {
        z: 11
        id: broadcatingBt
        anchors.left: parent.left
        width: 64 * scaleFactor
        height: width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        //opacity: broadcatingBt.pressed ? 0.5 : 1.0
        background: Image {
            source: "qrc:/icons/broadcasting_station.png"
            width: 40 * scaleFactor
            height: width
            anchors.centerIn: parent
            Text {
                text: playList.musicName === "" ?  qsTr("小原的 Solo Pro") : playList.musicName
                color: "white"
                font.pixelSize: 20 * scaleFactor
                anchors.left: parent.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Item {
    //     id: music_playlist_dawer_bottom
    //     width: parent.width
    //     height: parent.height
    //     z: 51
    //     MouseArea {anchors.fill: parent}
    //     x: 0
    //     y: height
    //     Behavior on y { PropertyAnimation { duration: control_duration; easing.type: Easing.OutQuad } }

    //     MouseArea {
    //         anchors.fill: parent
    //         drag.target: parent
    //         drag.minimumX: 0
    //         drag.minimumY: 0
    //         drag.maximumX: 0
    //         drag.maximumY: parent.height
    //         property int dragY
    //         onPressed: {
    //             dragY = parent.y
    //         }
    //         onReleased: {
    //             if (parent.y - dragY >= 100)
    //                 music_playlist_dawer_bottom.close()
    //             else
    //                 music_playlist_dawer_bottom.open()
    //         }
    //     }

    //     PlayList {
    //         id: playList
    //         anchors.fill: parent
    //     }

    //     function open() {
    //         control_duration = 200
    //         music_playlist_dawer_bottom.y = 0
    //     }

    //     function close() {
    //         music_playlist_dawer_bottom.y = height
    //     }
    // }
}
