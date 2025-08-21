/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 1990-2030. All rights reserved.
* @projectName   photoview
* @brief         DisplayPhoto.qml
* @author        Deng Zhimao
* @email         1252699831@qq.com
* @date          2020-07-16
*******************************************************************/
import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls 2.5
//import QtQml 2.12
import QtQuick.Layouts 1.12
Item {
    id: displayView
    Connections {
        target: photoListModel
        function onCurrentIndexChanged() {
            viewController.currentIndex = photoListModel.currentIndex
            //viewController.positionViewAtIndex(viewController.currentIndex, ListView.End)
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: window.height
        id: coverflowBg
        color: "white"
    }

    ListView  {
        id: viewController
        anchors.fill: parent
        model: photoListModel
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        highlightMoveDuration: currentIndex === viewController.count - 1 ? 0 : m_highlightMoveDuration
        Component.onCompleted: currentIndex = photoListModel.currentIndex
        onMovementEnded: {
            var index = Math.round(visibleArea.xPosition / (1 / photoListModel.count()))
            photoListModel.currentIndex = index
        }
        delegate: Image {
            id: imageShow
            width: displayView.width
            height: displayView.height
            source: path
            fillMode: Image.PreserveAspectCrop
            Button {
                id: bt
                opacity: 0
                anchors.fill: parent
                checkable: true
                enabled: imageShow.ListView.isCurrentItem
                onCheckedChanged: {
                    if (checked) {
                        row1.visible = false
                    } else {
                        if (imageShow.ListView.isCurrentItem)
                            row1.visible = true
                    }
                }
            }
            Connections {
                target: viewController
                function onCurrentIndexChanged() {
                    if (index !== viewController.currentIndex)
                        bt.checked = false
                }
            }
        }
        onCurrentIndexChanged: {
            row1.visible = true
        }
    }
    Row {
        id: row1
        visible: true
        anchors.bottom: parent.bottom
        anchors.bottomMargin: scaleFfactor * 10
        anchors.horizontalCenter: parent.horizontalCenter
        height: scaleFfactor * 40
        spacing:  scaleFfactor * 120
        Button {
            id: shareBt
            width: parent.height
            height: width
            opacity: 0.2
            background: Image {
                width: scaleFfactor * 25
                height: width
                anchors.centerIn: parent
                source: "qrc:/icons/share.png"
            }
        }

        Button {
            id: favariteBt
            width: parent.height
            height: width
            opacity: 0.2
            background: Image {
                width: scaleFfactor * 25
                height: width
                anchors.centerIn: parent
                source: "qrc:/icons/favorite.png"
            }
        }

        Button {
            id: infoBt
            width: parent.height
            height: width
            opacity: 0.2
            background: Image {
                width: scaleFfactor * 25
                height: width
                anchors.centerIn: parent
                source: "qrc:/icons/info.png"
            }
        }

        Button {
            id: deleteBt
            width: parent.height
            height: width
            opacity: deleteBt.pressed ? 0.8 : 1.0
            background: Image {
                width: scaleFfactor * 25
                height: width
                anchors.centerIn: parent
                source: "qrc:/icons/delete.png"
            }
            onClicked: {
                deletePage.visible = true
            }
        }
    }

    RowLayout {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        visible: row1.visible
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 60 * scaleFfactor
        spacing: 20
        Button {
            id: backBt
            Layout.preferredWidth: scaleFfactor * 40
            Layout.preferredHeight: Layout.preferredWidth
            opacity: backBt.pressed ? 0.8 : 1.0
            background:  Rectangle {
                anchors.fill: parent
                color: "#33101010"
                radius: height / 2
                Image {
                    width: scaleFfactor * 25
                    height: width
                    anchors.centerIn: parent
                    source: "qrc:/icons/back.png"
                }
            }
            onClicked: {
                swipeView.currentIndex = 0
            }
        }
        Item { Layout.fillWidth: true}
        Rectangle {
            Layout.preferredWidth: scaleFfactor * 40
            Layout.preferredHeight: Layout.preferredWidth
            color: "#33101010"
            radius: height / 2
            Text {
                text: viewController.currentIndex
                anchors.centerIn: parent
                font.pixelSize: 15 * scaleFfactor
                color: "white"
            }
        }
        Button {
            id: autoPlayBt
            Layout.preferredWidth: scaleFfactor * 100
            Layout.preferredHeight: scaleFfactor * 60
            checkable: true
            checked: false
            opacity: backBt.pressed ? 0.8 : 1.0
            background: Rectangle {
                width:  mText.contentWidth * 1.5 //scaleFfactor * 150
                height: scaleFfactor * 40
                anchors.centerIn: parent
                radius: height / 2
                //color: autoPlayBt.checked ? "#4ca2ff" : "#8101010"
                color: "#33101010"
                Text {
                    id: mText
                    text: autoPlayBt.checked ? qsTr("停止") : qsTr("幻灯片")
                    anchors.centerIn: parent
                    font.pixelSize: 15 * scaleFfactor
                    //color: autoPlayBt.checked ? "#4ca2ff" : "gray"
                    color:  "white"
                }
            }

            onCheckedChanged: {
                if (checked)
                    autoPlayTimer.restart()
                else
                    autoPlayTimer.stop()
            }
        }
    }
    Timer {
        id: autoPlayTimer
        repeat: true
        running: false
        interval: 3000
        onTriggered: {
            if (viewController.currentIndex + 1 >= viewController.count)
                viewController.currentIndex = 0
            else
                viewController.currentIndex++
        }
    }

    DeletePage {
        visible: false
        id: deletePage
    }

    Connections {
        target: photoViewLayout
        function onDeleteButtonClicked() {
            photoListModel.removeOne(viewController.currentIndex)
            if (viewController.count === 0) {
                displayView.visible = false
            }
        }
    }

    Connections {
        target: swipeView
        function onCurrentIndexChanged() {
            if (swipeView.currentIndex == 0)
                autoPlayTimer.stop()
            else {
                if (autoPlayBt.checked)
                    autoPlayTimer.restart()
            }
        }
    }
    onVisibleChanged: {
        if (visible) {
            if (swipeView.currentIndex == 0)
                autoPlayTimer.stop()
            else {
                if (autoPlayBt.checked)
                    autoPlayTimer.restart()
            }
        } else
            autoPlayTimer.stop()
    }
}
