/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         DashboardLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-05
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
Item {
    anchors.fill: parent
    Image {
        anchors.fill: parent
        source: "qrc:/images/bg.jpg"

    }

    onVisibleChanged: {
        if(!visible)
            dashBoardTimer.stop()
        else
            dashBoardTimer.start()
    }

    RowLayout {
        anchors.fill: parent
        DashBoard1 {
            width: 500 * scaleFacter
            id: dashBoard1
            Timer {
                id: dashBoardTimer
                repeat: true
                interval: 1500
                running: appMainBody.visible
                onTriggered: {
                    dashBoard1.accelerating = !dashBoard1.accelerating
                    dashBoard2.accelerating = !dashBoard1.accelerating
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }
        DashBoard2 {
            id: dashBoard2
            width: 500 * scaleFacter
        }
    }

    Button {
        id: modelShowButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 20
        width: modelShowButtonText.width * 1.5
        height: 60 * scaleFacter
        checkable: true
        checked: false

        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            border.color: "#057c78"
            border.width: 1
            opacity: modelShowButton.pressed ? 0.8 : 1.0
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#057c78" }
                GradientStop { position: 1.0; color: "#1b37a5" }
            }
            Text {
                id: modelShowButtonText
                text: qsTr("剩余99公里")
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 20 * scaleFacter
                opacity: !modelShowButton.checked ? 1.0 : 0.8
            }
        }
    }

    Image {
        id: leftTurn
        source: "qrc:/icons/left.png"
        width: 64 * scaleFacter
        height: width
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 100 * scaleFacter
        anchors.top: parent.top
        anchors.topMargin: 100 * scaleFacter
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }


    Image {
        id: rightTurn
        source: "qrc:/icons/right.png"
        width: 64 * scaleFacter
        height: width
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 100 * scaleFacter
        anchors.top: parent.top
        anchors.topMargin: 100 * scaleFacter
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }

    Timer {
        running: dashBoardTimer.running
        interval: 600
        repeat: true
        onTriggered: {
            if (leftTurn.opacity === 1) {
                leftTurn.opacity = 0
                rightTurn.opacity = 0
            } else {
                leftTurn.opacity = 1
                rightTurn.opacity = 1
            }
        }
    }


    Rectangle {
        width: 180 * scaleFacter
        height: 200 * scaleFacter
        color: "#AA101010"
        radius: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 120 * scaleFacter
        Text {
            text: qsTr("P")
            anchors.centerIn: parent
            font.pixelSize: 80 * scaleFacter
            color: "white"
            font.bold: true
        }
    }
}
