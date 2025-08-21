/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   photoview
* @brief         PhotoListView.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-02-24
*******************************************************************/
import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.3
import com.alientek.qmlcomponents 1.0
Item {
    Rectangle {
        visible: false
        id: photoListView_drawer_bottom
        width: parent.width
        height: parent.height
        z: 10
        color: "#55101010"
        x: 0
        y: height
        Behavior on y { PropertyAnimation { duration: 250; easing.type: Easing.OutQuad } }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                photoListView_drawer_bottom.close()
            }
        }

        function open() {
            photoListView_drawer_bottom.y = 0
        }

        function close() {
            photoListView_drawer_bottom.y = height

        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: photoGridView.currentIndex === -1 ? photoGridView.contentHeight + photoGridView.cellHeight : height
        contentWidth: parent.width

        GridView  {
            id: photoGridView
            anchors.top: parent.top
            anchors.topMargin: scaleFfactor * 100
            anchors.left: parent.left
            anchors.right: parent.right
            height: contentHeight
            focus: true
            clip: false
            interactive: false
            cellWidth: photoGridView.width / 5
            cellHeight: photoGridView.width / 5
            snapMode: GridView.SnapOneRow
            currentIndex: -1
            model: photoListModel
            onCountChanged : {
                currentIndex = -1
            }
            delegate: Rectangle {
                id: itembg
                width: photoGridView.cellWidth
                height: photoGridView.cellWidth
                color: "transparent"
                Image {
                    id: photo
                    source: path
                    width: parent.width - 5
                    height: parent.height - 5
                    anchors.centerIn: parent
                    smooth: true
                    fillMode: Image.PreserveAspectCrop
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        m_highlightMoveDuration = 0
                        photoListModel.currentIndex = index
                        swipeView.currentIndex = 1
                        m_highlightMoveDuration = 200
                    }
                }
            }
        }
    }

    Rectangle {
        //visible: photoGridView.currentIndex === -1
        visible: false
        height: scaleFfactor * 60
        radius: height / 2
        width: parent.width - scaleFfactor * 50
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.8
        anchors.bottom: bottomRect.top
        anchors.bottomMargin: scaleFfactor * 10
        color: "#f0f0f0"

        Rectangle {
            id: bg_rect
            height: parent.height - scaleFfactor * 20
            width: bt_all.width + scaleFfactor * 40
            radius: height / 2
            color: "#9f9f9f"
            x: bt_all.x + bt_all.width / 2 - scaleFfactor * 15
            anchors.verticalCenter: parent.verticalCenter
            Behavior on x { PropertyAnimation { duration: 250; easing.type: Easing.Linear } }
            Behavior on width { PropertyAnimation { duration: 250; easing.type: Easing.Linear } }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            spacing: scaleFfactor * 20//(parent.width - bt_year.width - bt_all.width - bt_day.width - bt_month.width) / 3
            RadioButton {
                id: bt_year
                background: Item {}
                width: text_year.contentWidth * 4
                height: parent.height
                indicator: Item {}
                Text {
                    id: text_year
                    text: qsTr("年")
                    color:  bt_year.checked ? "white" : "#9f9f9f"
                    font.pixelSize: scaleFfactor * 30
                    anchors.centerIn: parent
                    font.bold: true
                }
                onClicked: {
                    bg_rect.width = bt_year.width
                    bg_rect.x =  bt_year.x + bt_year.width / 2
                }
            }

            RadioButton {
                id: bt_month
                background: Item {}
                width: text_month.contentWidth * 4
                height: parent.height
                indicator: Item {}
                Text {
                    id: text_month
                    text: qsTr("月")
                    color: bt_month.checked ? "white" : "#9f9f9f"
                    font.pixelSize: scaleFfactor * 30
                    anchors.centerIn: parent
                    font.bold: true
                }
                onClicked: {
                    bg_rect.width = bt_month.width
                    bg_rect.x =  bt_month.x + bt_month.width / 2
                }
            }

            RadioButton {
                id: bt_day
                background: Item {}
                width: text_day.contentWidth * 4
                height: parent.height
                indicator: Item {}
                Text {
                    id: text_day
                    text: qsTr("日")
                    color: bt_day.checked ? "white" : "#9f9f9f"
                    font.pixelSize: scaleFfactor * 30
                    anchors.centerIn: parent
                    font.bold: true
                }
                onClicked: {
                    bg_rect.width = bt_day.width
                    bg_rect.x =  bt_day.x + bt_day.width / 2
                }
            }

            RadioButton {
                id: bt_all
                background: Item {}
                width: text_day.contentWidth * 4
                height: parent.height
                indicator: Item {}
                checked: true
                Text {
                    id: text_all
                    text: qsTr("所有照片")
                    color: bt_all.checked ? "white" : "#9f9f9f"
                    font.pixelSize: scaleFfactor * 30
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }
                onClicked: {
                    bg_rect.width =  bt_all.width + scaleFfactor * 40
                    bg_rect.x =  bt_all.x + bt_all.width / 2 - scaleFfactor * 15
                }
            }
        }
    }

    Rectangle {
        id: bottomRect
        visible: false
        anchors.bottom: parent.bottom
        height: scaleFfactor * 120
        width: parent.width
        color: "#f7f7f5"
        MouseArea {
            anchors.fill: parent
        }
        Row {
            id: photoListView_row1
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: scaleFfactor * 20

            RadioButton {
                id: bt_photo
                checked: true
                width: scaleFfactor * 150
                height: width
                opacity: bt_photo.pressed ? 0.5 : 1.0
                contentItem: Item {
                    anchors.fill: parent
                    Image {
                        id: image_photo
                        anchors.top: parent.top
                        anchors.topMargin: scaleFfactor * 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: bt_photo.checked ? "qrc:/icons/photo_checked.png" : "qrc:/icons/photo_unchecked.png"
                        width: scaleFfactor * 64
                        height: width
                    }
                    Text {
                        font.pixelSize: scaleFfactor * 20
                        text: qsTr("图库")
                        font.family: "Montserrat Light"
                        anchors.top: image_photo.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: bt_photo.checked ? "#0b86fd" : "#9f9f9f"
                    }
                }
                indicator: Item {
                }
            }

            RadioButton {
                id: bt_recommend
                checked: false
                width: scaleFfactor * 150
                height: width
                enabled: false
                opacity: bt_recommend.pressed ? 0.5 : 1.0
                contentItem: Item{
                    anchors.fill: parent
                    Image {
                        id: image_recommend
                        anchors.top: parent.top
                        anchors.topMargin: scaleFfactor * 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: bt_recommend.checked ? "qrc:/icons/recommand_checked.png" : "qrc:/icons/recommand_unchecked.png"
                        width: scaleFfactor * 64
                        height: width
                    }
                    Text {
                        font.pixelSize: scaleFfactor * 20
                        text: qsTr("为你推荐")
                        font.family: "Montserrat Light"
                        anchors.top: image_recommend.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: bt_recommend.checked ? "#0b86fd" : "#9f9f9f"
                    }
                }
                indicator: Item {
                }
            }

            RadioButton {
                id: bt_album
                checked: false
                width: scaleFfactor * 150
                height: width
                opacity: bt_album.pressed ? 0.5 : 1.0
                contentItem: Item{
                    anchors.fill: parent
                    Image {
                        id: image_album
                        anchors.top: parent.top
                        anchors.topMargin: scaleFfactor * 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: bt_album.checked ? "qrc:/icons/album_checked.png" : "qrc:/icons/album_unchecked.png"
                        width: scaleFfactor * 64
                        height: width
                    }
                    Text {
                        font.pixelSize: scaleFfactor * 20
                        text: qsTr("相簿")
                        font.family: "Montserrat Light"
                        anchors.top: image_album.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: bt_album.checked ? "#0b86fd" : "#9f9f9f"
                    }
                }
                indicator: Item {
                }
            }

            RadioButton {
                id: bt_search
                checked: false
                width: scaleFfactor * 150
                height: width
                enabled: false
                opacity: bt_album.pressed ? 0.5 : 1.0
                contentItem: Item{
                    anchors.fill: parent
                    Image {
                        id: image_search
                        anchors.top: parent.top
                        anchors.topMargin: scaleFfactor * 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: bt_search.checked ? "qrc:/icons/search_checked.png" : "qrc:/icons/search_unchecked.png"
                        width: scaleFfactor * 64
                        height: width
                    }
                    Text {
                        font.pixelSize: scaleFfactor * 20
                        text: qsTr("搜索")
                        font.family: "image_search Light"
                        anchors.top: image_search.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: bt_search.checked ? "#0b86fd" : "#9f9f9f"
                    }
                }
                indicator: Item {
                }
            }
        }
    }

    Rectangle {
        visible: flickable.contentY >= scaleFfactor * 15
        anchors.top: parent.top
        width: parent.width
        height: scaleFfactor * 200
        opacity: 0.5
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Text {
        id: time_text
        text: qsTr("2023年5月20日")
        color: flickable.contentY >= scaleFfactor * 30 ? "white" : "black"
        font.pixelSize: scaleFfactor * 25
        anchors.top: parent.top
        anchors.topMargin: scaleFfactor * 10
        anchors.left: parent.left
        anchors.leftMargin: scaleFfactor * 25
        font.bold: true
        Behavior on color { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
    }

    Text {
        id: place_text
        text: qsTr("广州市 - 白云区")
        color: time_text.color
        font.pixelSize: scaleFfactor * 20
        anchors.top: time_text.bottom
        anchors.topMargin: scaleFfactor * 10
        anchors.left: time_text.left
    }

    Button {
        visible: false
        id: bt_chose
        anchors.verticalCenter: time_text.verticalCenter
        width: scaleFfactor * 100
        height: scaleFfactor * 60
        anchors.right: bt_info.left
        anchors.rightMargin: scaleFfactor * 10
        Text {
            id: chose_text
            text: qsTr("选择")
            font.pixelSize: scaleFfactor * 25
            anchors.centerIn: parent
            color: flickable.contentY >= scaleFfactor * 30  ? "white" : "#0b86fd"
        }
        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "#f0f0f0"
            opacity:flickable.contentY >= scaleFfactor * 30  ? 0.5 : 0.8
        }
    }

    Button {
        visible: false
        id: bt_info
        anchors.verticalCenter: time_text.verticalCenter
        width: scaleFfactor * 60
        height: width
        anchors.right: parent.right
        anchors.rightMargin: scaleFfactor * 25
        Text {
            id: info_text
            text: qsTr("❤")
            font.pixelSize: scaleFfactor * 25
            anchors.centerIn: parent
            color: flickable.contentY >= scaleFfactor * 30  ? "white" : "#0b86fd"
        }
        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "#f0f0f0"
            opacity:flickable.contentY >= scaleFfactor * 30  ? 0.5 : 0.8
        }
    }
}
