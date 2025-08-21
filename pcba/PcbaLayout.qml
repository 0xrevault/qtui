/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         PcbaLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-06-03
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import com.alientek.qmlcomponents 1.0
Item {
    anchors.fill: parent

    function translateText(text) {
        const translations = {
            "测试中": qsTr("测试中"),
            "已完成": qsTr("已完成"),
            "未测试": qsTr("未测试"),
            "成功": qsTr("成功"),
            "失败": qsTr("失败"),
            "蓝牙": qsTr("蓝牙"),
            "TF卡座子": qsTr("TF卡座子"),
            "pcie接口": qsTr("pcie接口"),
            "底板MIC": qsTr("底板MIC"),
            "用户按键": qsTr("用户按键"),
            "电位器": qsTr("电位器"),
            "usb接口": qsTr("usb接口"),
            "耳机座子": qsTr("耳机座子"),
            "底板喇叭": qsTr("底板喇叭"),
        };
        return translations[text] || text;
    }

    PcbaListModel {
        id: pcbaListModel
        /*Component.onCompleted: {
             pcbaListModel.add(appCurrtentDir + "/pcba.cfg")
         }*/
        onManualLogChanged: {
            logTextArea.text =  logTextArea.text + pcbaListModel.manualLog
        }
        onCurrentTitleChanged: currtentTestItem.text = currentTitle
    }

    Rectangle {
        color: "#3D9140"
        anchors.top: parent.top
        width: parent.width
        height: scaleFactor *  64
        Text {
            text: qsTr("正点原子测试程序(非专业人员勿测)")
            color: "white"
            font.pixelSize: 40
            anchors.centerIn: parent
            font.bold: true
        }
    }

    Rectangle {
        id: topRect
        color: "#808069"
        anchors.top: parent.top
        anchors.topMargin: scaleFactor *  64
        width: parent.width
        height: scaleFactor *  64

        Row {
            id: row1
            anchors.centerIn: parent

            Text {
                width: topRect.width / 4
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                font.pixelSize: 35
                text: qsTr("测试项目")
                font.bold: true
            }

            Text {
                width: topRect.width / 4
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                font.pixelSize: 35
                text: qsTr("测试类型")
                font.bold: true
            }

            Text {
                width: topRect.width / 4
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                font.pixelSize: 35
                text: qsTr("测试进度")
                font.bold: true
            }

            Text {
                width: topRect.width / 4
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                font.pixelSize: 35
                text: qsTr("测试结果")
                font.bold: true
            }
        }
    }


    ListView {
        id: listView
        anchors.top: topRect.bottom
        width: parent.width
        anchors.bottom: row2.top
        model: pcbaListModel
        clip: true
        onFlickStarted: scrollBar2.opacity = 1.0
        onFlickEnded: scrollBar2.opacity = 0.5
        ScrollBar.vertical: ScrollBar {
            id: scrollBar2
            width: 10
            opacity: 1.0
            anchors.right: parent.right
            onActiveChanged: {
                active = true;
            }
            Component.onCompleted: {
                scrollBar2.active = true;
            }
            contentItem: Rectangle{
                implicitWidth: 6
                implicitHeight: 100
                radius: 2
                color: scrollBar2.hovered ? "#88ffffff" : "#ffffffff"
            }
            Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
        }
        delegate: Rectangle {
            width: listView.width
            height: scaleFactor * 64
            color: mouseArea.pressed ? "#88d7c388" : "transparent"
            Behavior on color { PropertyAnimation { duration: 200; easing.type: Easing.InOutBack } }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    pcbaListModel.currentIndex = index
                    //listView.currentIndex = index // 这里有一些奇怪的BUG
                    if (manual) {
                        logMouseArea.visible = true
                        pcbaListModel.manualTest()
                    } else
                        pcbaListModel.singleTest()
                }
            }

            Row {
                anchors.centerIn: parent
                Text {
                    width: mouseArea.width / 4
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                    font.pixelSize: 30
                    text: translateText(title)
                }

                Text {
                    width:  mouseArea.width / 4
                    horizontalAlignment: Text.AlignHCenter
                    color: manual ? "#03A89E" : "white"
                    font.pixelSize: 30
                    text: manual ? qsTr("手动") : qsTr("自动")
                }


                Text {
                    width:  mouseArea.width / 4
                    horizontalAlignment: Text.AlignHCenter
                    color: if (translateText(processState) === qsTr("已完成"))
                               return "green"
                           else if (translateText(processState) === qsTr("测试中"))
                               return "#E3CF57"
                           else
                               return "red"
                    font.pixelSize: 30
                    text: translateText(processState)
                }

                Text {
                    width:  mouseArea.width / 4
                    horizontalAlignment: Text.AlignHCenter
                    color: translateText(result) === qsTr("成功") ? "green" : "red"
                    font.pixelSize: 30
                    text: translateText(result)
                }
            }
            Rectangle {
                height: 1
                width: parent.width
                color: "gray"
                anchors.bottom: parent.bottom
            }
        }
    }

    Row {
        id: row2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        enabled:  !loader.sourceComponent
        Button {
            id: bt_auto
            width: window.width / 2
            height: scaleFactor *  64
            background: Rectangle {
                anchors.fill: parent
                color: bt_auto.pressed ? "#2E8B57" : "green"
                Text {
                    width: 200
                    font.pixelSize: 30
                    text: qsTr("自动")
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                pcbaListModel.autoTest()
                loader.text = qsTr("自动测试项开始运行")
                loader.sourceComponent = component
            }
        }

        Button {
            id: bt_check
            width: window.width / 2
            height: scaleFactor *  64
            enabled: pcbaListModel.logfileIsReady &&  !loader.sourceComponent
            background: Rectangle {
                anchors.fill: parent
                color: bt_check.pressed ? "#2E8B57" : (pcbaListModel.logfileIsReady ? "green" : "gray")
                Text {
                    width: 200
                    font.pixelSize: 30
                    text: qsTr("查看记录")
                    color: pcbaListModel.logfileIsReady ? "white" : "#A0A0A0"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                loader1.sourceComponent = component1
                pcbaListModel.checkLog()
                loader.text = qsTr("已为你打开记录")
                loader.sourceComponent = component
            }
        }
    }

    function closeFunc() {
        logMouseArea.visible = false
        logTextArea.clear()
        pcbaListModel.exitTest()
    }

    MouseArea {
        id: logMouseArea
        visible: false
        width: parent.width
        height: parent.height
        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        Rectangle {
            width: parent.width
            height: scaleFactor *  64
            color: "#3D9140"
            Text {
                id: currtentTestItem
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 40
            }
        }
        Item {
            width: parent.width
            anchors.centerIn: parent
            height: parent.height - 200
            clip: true
            Flickable {
                id: filckable
                anchors.fill: parent
                contentHeight: logTextArea.contentHeight + 1
                onFlickStarted: scrollBar.opacity = 1.0
                onFlickEnded: scrollBar.opacity = 0.0
                ScrollBar.vertical: ScrollBar {
                    id: scrollBar
                    width: 10
                    opacity: 0.0
                    anchors.right: parent.right
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
                        color: scrollBar.hovered ? "#88ffffff" : "#ffffffff"
                    }
                    Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
                }

                TextArea {
                    anchors.fill: parent
                    id: logTextArea
                    font.pixelSize: 30
                    color: "white"
                    onTextChanged: scrollBar.increase()
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            //anchors.bottomMargin: window.width / 720 * 50
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Button {
                id: bt_ok
                enabled: !loader.sourceComponent
                width:  window.width / 4
                height: scaleFactor *  64
                background: Rectangle {
                    anchors.fill: parent
                    color: bt_ok.pressed ? "#2E8B57" : "green"
                    Text {
                        text: qsTr("成功")
                        color: "white"
                        font.pixelSize: 30
                        anchors.centerIn: parent
                    }
                }
                onClicked: {
                    pcbaListModel.setItemSuccess(qsTr("成功"))
                    pcbaListModel.exitTest()
                    loader.text = qsTr("已确认成功")
                    loader.sourceComponent = component
                }
            }

            Button {
                id: bt_failed
                width:  window.width / 4
                height: bt_ok.height
                enabled:  !loader.sourceComponent
                background: Rectangle {
                    anchors.fill: parent
                    color: bt_failed.pressed ? "black" : "red"
                    Text {
                        text: qsTr("失败")
                        color: "white"
                        font.pixelSize: 30
                        anchors.centerIn: parent
                    }
                }
                onClicked: {
                    pcbaListModel.setItemSuccess(qsTr("失败"))
                    pcbaListModel.exitTest()
                    loader.text = qsTr("已确认失败")
                    loader.sourceComponent = component
                }
            }

            Button {
                id: bt_next
                width:  window.width / 4
                height: bt_ok.height
                enabled: pcbaListModel.currentIndex !== pcbaListModel.count - 1 &&  !loader.sourceComponent
                background: Rectangle {
                    anchors.fill: parent
                    color: bt_next.pressed ? "#2E8B57"  : (pcbaListModel.currentIndex === pcbaListModel.count - 1) ? "gray" : "green"
                    Text {
                        id: next_text
                        text: qsTr("下一项")
                        color: (pcbaListModel.currentIndex === pcbaListModel.count - 1) ? "#A0A0A0" :"white"
                        font.pixelSize: 30
                        anchors.centerIn: parent
                    }
                }
                onClicked: {
                    if (pcbaListModel.currentIndex !== pcbaListModel.count - 1) {
                        logTextArea.clear()
                        pcbaListModel.exitTest()
                        pcbaListModel.currentIndex++
                        pcbaListModel.manualTest()
                        loader.text = qsTr("已为你切换到下一项")
                        loader.sourceComponent = component
                    }
                }
            }

            Button {
                id: bt_close
                width:  window.width / 3.8
                height: bt_ok.height
                background: Rectangle {
                    anchors.fill: parent
                    color: bt_close.pressed ? "black" : "green"
                    Text {
                        text: qsTr("返回")
                        color: "white"
                        font.pixelSize: 30
                        anchors.centerIn: parent
                    }
                }
                onClicked: {
                    closeFunc()
                }
            }
        }
    }

    Loader {
        anchors.fill: parent
        id: loader1
        asynchronous: false
    }

    Component {
        id: component1
        Rectangle {
            color: "black"
            Rectangle {
                width: parent.width
                height: scaleFactor *  64
                color: "#3D9140"
                id: topRect1
                Text {
                    anchors.centerIn: parent
                    text: qsTr("测试记录")
                    color: "white"
                    font.bold: true
                    font.pixelSize: 40
                }
            }
            Connections {
                target: pcbaListModel
                function onLogTxtContentChanged(testTiltle, testResult, testTime) {
                    listView1.model.insert(listView1.model.count, {"testTiltle": translateText(testTiltle), "testResult": translateText(testResult), "testTime": translateText(testTime)})
                }
            }
            ListView {
                id: listView1
                anchors.top: topRect1.bottom
                width: parent.width
                anchors.bottom: bt_back.top
                clip: true
                model: ListModel{ id: listmodel }
                onFlickStarted: scrollBar1.opacity = 1.0
                onFlickEnded: scrollBar1.opacity = 0.0
                ScrollBar.vertical: ScrollBar {
                    id: scrollBar1
                    width: 10
                    opacity: 0.0
                    anchors.right: parent.right
                    onActiveChanged: {
                        active = true;
                    }
                    Component.onCompleted: {
                        scrollBar1.active = true;
                    }
                    contentItem: Rectangle{
                        implicitWidth: 6
                        implicitHeight: 100
                        radius: 2
                        color: scrollBar1.hovered ? "#88ffffff" : "#ffffffff"
                    }
                    Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
                }
                delegate: Item {
                    width: parent.width
                    height: scaleFactor * 64
                    Rectangle {
                        height: 1
                        width: parent.width
                        color: "gray"
                        anchors.bottom: parent.bottom
                    }

                    Row {
                        spacing: 0
                        height: scaleFactor *  64
                        Text {
                            width: window.width / 4
                            height: scaleFactor *  64
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                            font.pixelSize: 30
                            text: testTiltle
                        }

                        Text {
                            width: window.width / 4
                            height: scaleFactor *  64
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: testResult === qsTr("成功") ? "green" : "red"
                            font.pixelSize: 30
                            text: testResult
                        }

                        Text {
                            width: window.width / 2
                            height: scaleFactor *  64
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                            font.pixelSize: 30
                            text: testTime
                        }
                    }
                }
            }

            Button {
                id: bt_back
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                width: parent.width
                height: scaleFactor *  64
                background: Rectangle {
                    anchors.fill: parent
                    color: bt_back.pressed ?  "#2E8B57" : "green"
                    Text {
                        text: qsTr("返回")
                        color: "white"
                        font.pixelSize: 40
                        anchors.centerIn: parent
                    }
                }
                onClicked: {
                    loader1.sourceComponent = undefined
                }
            }
        }
    }


    Loader {
        anchors.fill: parent
        id: loader
        asynchronous: false
        property string text
        sourceComponent: undefined
    }

    Component {
        id: component
        Item {
            Rectangle {
                anchors.centerIn: parent
                width: colum1.width + 100
                height: colum1.height + 100
                color: "gray"
                Column {
                    id: colum1
                    spacing: 25
                    anchors.centerIn: parent
                    Text {
                        text: qsTr("提示")
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "green"
                        font.pixelSize: 45
                    }
                    Text {
                        id: tipsText
                        text: loader.text//qsTr("写入成功！")
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Timer {
                running: true
                interval: 500
                repeat: false
                onTriggered: loader.sourceComponent = undefined
            }
        }
    }
}
