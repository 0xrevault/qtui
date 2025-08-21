/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         CameraLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-25
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import com.alientek.qmlcomponents 1.0
Rectangle {
    anchors.fill: parent
    color: "black"
    id: displayView

    PhotoListModel {
        id: photoListModel
        Component.onCompleted:  {
            photoListModel.add(appCurrtentDir + "/resource/images/");
        }
    }

    Timer {
        id: delayToexec
        repeat: false
        function setTimeout(func, delayTime) {
            delayToexec.stop()
            delayToexec.interval = delayTime
            delayToexec.triggered.connect(func)
            delayToexec.triggered.connect(function release () {
                delayToexec.triggered.disconnect(func)
                delayToexec.triggered.disconnect(release)
            })
            delayToexec.start()
        }
    }

    Camera {
        id: camera
        Component.onCompleted: camera.play()
        path: appCurrtentDir + "/resource/images/"
        onImageCapture: {
            console.log("IMG has been saved in " + fileName)
            photoListModel.addPhoto(fileName)
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: camera.image
    }

    ListModel {
        id: listmodelModelSelect
        ListElement {name: "慢动作"}
        ListElement {name: "照片"}
        ListElement {name: "视频"}
        ListElement {name: "正方形"}
        ListElement {name: "全景"}
    }

    Item {
        id: middleWidget
        anchors.right: parent.right
        width: 90 * scaleFfactor
        height: parent.height
        Image {
            id: capturePhoto
            source: photoListModel.currentIndex !== -1  ? photoListModel.getcurrentPath() : ""
            width: scaleFfactor * 55
            anchors.horizontalCenter: parent.horizontalCenter
            height: width
            fillMode: Image.PreserveAspectCrop
            visible: false
            anchors.bottom: parent.verticalCenter
            anchors.bottomMargin: 100 * scaleFfactor
        }
        Rectangle {
            id: capturePhoto_mask
            anchors.fill: capturePhoto
            radius: scaleFfactor * 5
            visible: false
        }

        OpacityMask {
            id: capturePhoto_opacitymask
            source: capturePhoto
            maskSource: capturePhoto_mask
            visible: true
            anchors.fill: capturePhoto
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    viewController.visible = true
                    viewController.positionViewAtIndex(viewController.currentIndex, ListView.Beginning)
                    camera.stop()
                }
            }
        }

        RoundButton {
            id: roundButton1
            anchors.centerIn: parent
            width: scaleFfactor * 60
            height: width
            background: Rectangle {
                anchors.fill: parent
                radius:  height / 2
                border.color: "white"
                border.width: scaleFfactor * 4
                color: "transparent"
                Rectangle {
                    width: roundButton1.pressed ? scaleFfactor * 45 : scaleFfactor * 48
                    height: roundButton1.pressed ? scaleFfactor * 45 : scaleFfactor * 48
                    Behavior on width { PropertyAnimation { duration: 100; easing.type: Easing.Linear } }
                    Behavior on height { PropertyAnimation { duration: 100; easing.type: Easing.Linear } }
                    color: "white"
                    radius: height / 2
                    anchors.centerIn: parent
                }
            }

            onClicked: {
                camera.takeImage()
            }
        }

        Tumbler {
            id: tumbler
            visible: false
            model: listmodelModelSelect
            width: parent.width
            height: parent.height / 3
            anchors.top: parent.verticalCenter
            anchors.topMargin: roundButton1.height / 2 + 30
            visibleItemCount: 3
            currentIndex: 1
            //wrap: false
            delegate: Item {
                height: 50
                width: 50
                Rectangle {
                    anchors.centerIn: parent
                    width: 80
                    height: 30
                    radius: height / 2
                    color: tumbler.currentIndex === index ? "#88101010" : "transparent"
                    Text {
                        text: name
                        color: tumbler.currentIndex === index ? "#FFD700" : "white"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tumbler.currentIndex = index
                    }
                }
            }
        }
    }

    Connections {
        target: photoListModel
        function onCurrentIndexChanged() {
            viewController.currentIndex = photoListModel.currentIndex
            thumbnailListView.currentIndex = photoListModel.currentIndex
        }
    }
    Connections {
        target: viewController
        function onVisibleChanged() {
            if (viewController.visible && autoPlayBt.checked)
                autoPlayTimer.restart()
            else
                autoPlayTimer.stop()
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: viewController.visible
    }

    ListView  {
        visible: false
        id: viewController
        anchors.fill: parent
        model: photoListModel
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        highlightMoveDuration: currentIndex === viewController.count - 1 ? 0 : 200
        Component.onCompleted: {
            currentIndex = photoListModel.currentIndex
        }

        onMovementEnded: {
            var index = Math.round(visibleArea.xPosition / (1 / photoListModel.count()))
            photoListModel.currentIndex = index
        }
        onCurrentIndexChanged: {
            photoListModel.currentIndex = viewController.currentIndex
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
                        bottomWidgets.visible = false
                    } else {
                        if (imageShow.ListView.isCurrentItem)
                            bottomWidgets.visible = true
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
    }
    /*PathView  {
        visible: false
        id: viewController
        anchors.fill: parent
        pathItemCount: 3
        model: photoListModel
        snapMode: PathView.SnapOneItem
        delegate: Image {
            id: imageShow
            width: parent.width
            height: parent.height
            source: path
            scale: bt.checked && imageShow.PathView.isCurrentItem ? 1.0 : PathView.viewScale
            z: PathView.viewZ
            opacity: PathView.viewOpacity
            Behavior on scale { PropertyAnimation {id: animation; duration: varDuration; easing.type: Easing.Linear } }
            Button {
                id: bt
                opacity: 0
                anchors.fill: parent
                checkable: true
                enabled: imageShow.PathView.isCurrentItem
                onCheckedChanged: {
                    if (checked) {
                        varDuration = 200
                        bottomWidgets.visible = false
                    } else {
                        if (imageShow.PathView.isCurrentItem)
                            bottomWidgets.visible = true
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
            varDuration = 0
            photoListModel.currentIndex = viewController.currentIndex
        }

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        path:  Path {
            id: viewControllerPath
            startX: - viewController.width // /2
            startY: viewController.height / 2

            PathAttribute { name: "viewScale"; value: 1.0} // 0.5
            PathAttribute { name: "viewZ"; value: 0}
            PathAttribute { name: "viewOpacity"; value:1.0}

            PathLine { x: viewController.width / 2 ; y: viewController.height / 2}
            PathAttribute { name: "viewScale"; value: 1.0}
            PathAttribute { name: "viewZ"; value: 5}
            PathAttribute { name: "viewOpacity"; value: 1.0}

            PathLine { x: viewController.width + viewController.width; y:viewController.height / 2} //x: + xx/2
            PathAttribute { name: "viewScale"; value: 1.0 }
            PathAttribute { name: "viewZ"; value: 0}
            PathAttribute { name: "viewOpacity"; value: 1.0}
            PathPercent { value: 1.0}
        }
    }*/

    Rectangle {
        id: bottomWidgets
        visible: viewController.visible
        color: "white"
        anchors.bottom: parent.bottom
        height: scaleFfactor *  60
        width: parent.width
        MouseArea {
            anchors.fill: parent
        }

        ListView {
            id: thumbnailListView
            height: parent.height - 30
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 2
            orientation: ListView.Horizontal
            clip: true
            model: photoListModel
            snapMode: ListView.SnapOneItem
            delegate:  Rectangle {
                width: photoListModel.currentIndex === index ?  height : height / 2 + 5
                height: thumbnailListView.height
                Image {
                    width: photoListModel.currentIndex === index ?  height : height / 2
                    height: thumbnailListView.height
                    fillMode: Image.PreserveAspectCrop
                    source: path
                    anchors.centerIn: parent
                    opacity: mouseArea2.pressed ? 0.8 : 1.0
                    Behavior on width { PropertyAnimation { duration: 100; easing.type: Easing.OutQuart } }
                }
                MouseArea {
                    id: mouseArea2
                    anchors.fill: parent
                    onClicked: {
                        photoListModel.currentIndex = index
                    }
                }
            }
        }
    }

    RowLayout {
        id: topWidgets
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        visible: bottomWidgets.visible
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 60 * scaleFfactor
        spacing: 20
        Button {
            id: backBt
            Layout.preferredWidth: scaleFfactor * 40
            Layout.preferredHeight: Layout.preferredWidth
            opacity: backBt.pressed ? 0.8 : 1.0
            background: Rectangle {
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
                viewController.visible = false
                bottomWidgets.visible = false
                autoPlayTimer.stop()
                camera.play()
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
            id: deleteBt
            Layout.preferredWidth: scaleFfactor * 40
            Layout.preferredHeight: Layout.preferredWidth
            opacity: deleteBt.pressed ? 0.8 : 1.0
            background: Rectangle {
                anchors.fill: parent
                color: "#33101010"
                radius: height / 2
                Image {
                    width: parent.width / 2
                    height: width
                    source: "qrc:/icons/delete.png"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                deletePage.visible = true
                autoPlayBt.checked = false
            }
        }

        Button {
            id: autoPlayBt
            Layout.preferredWidth: scaleFfactor * 100
            Layout.preferredHeight: scaleFfactor * 40
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
        onTriggered: viewController.currentIndex++
    }


    DeletePage {
        visible: false
        id: deletePage
        onDeleteButtonClicked:{
            photoListModel.removeOne(viewController.currentIndex)
            if (viewController.count === 0) {
                viewController.visible = false
                bottomWidgets.visible = false
                autoPlayTimer.stop()
            }
        }
    }
}
