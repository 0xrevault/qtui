/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ChatWindow.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0
Item {
    property int defaultHeight: 80 * scaleFfactor
    ListView {
        id: chatWindowListView
        clip: true
        anchors.top: friendText.bottom
        anchors.topMargin: 15 * scaleFfactor
        width: parent.width
        anchors.bottom: inputRect.top
        model: chatModel
        spacing: 10
        onCountChanged: {
            chatWindowListView.currentIndex = chatWindowListView.count - 1
        }
        onFlickStarted: scrollBar.opacity = 1.0
        onFlickEnded: scrollBar.opacity = 0.0
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            width: scaleFfactor * 8
            opacity: 0.0
            onActiveChanged: {
                active = true;
            }
            Component.onCompleted: {
                scrollBar.active = true;
            }
            contentItem: Rectangle{
                implicitWidth: scaleFfactor * 6
                implicitHeight: scaleFfactor * 100
                radius: scaleFfactor * 2
                color: scrollBar.hovered ? "#101010" : "#88101010"
            }
            Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
        }

        delegate: Item {
            id: delegateItem
            LayoutMirroring.enabled: chatMessage.user === ChatModel.ARM64
            LayoutMirroring.childrenInherit: chatMessage.user === ChatModel.ARM64
            width: window.width
            height: defaultHeight > messaage.height * 1.2 ? defaultHeight : messaage.height * 1.2
            Row {
                id: row
                spacing: 20
                anchors.left: parent.left
                anchors.leftMargin: 50
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                Item {
                    id: rectBg
                    width: defaultHeight - 10
                    height: width
                    // color: "#c4c4c4"
                    // radius: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: chatHeads
                        source: chatMessage.user === ChatModel.OtherDevice ? "qrc:/icons/m33.png" : "qrc:/icons/arm64.png"
                        sourceSize: Qt.size(rectBg.width, rectBg.height)
                        smooth: true
                        visible: false
                    }

                    Rectangle {
                        id: mask
                        anchors.fill: rectBg
                        radius: 10
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: rectBg
                        source: chatHeads
                        maskSource: mask
                    }
                }

                Item {
                    id: textContent
                    width: delegateItem.width / 2
                    height: messaage.height * 1.2
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        anchors.left: parent.left
                        width: messaage.contentWidth
                        height: messaage.height * 1.2
                        radius: height / 8
                        color:chatMessage.user === ChatModel.OtherDevice ? "white" : "#95ec69"
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            width: 20 * scaleFfactor
                            height: width
                            rotation: 45
                            color: parent.color
                            radius: 4 * scaleFfactor
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: -width / 2 + 4 * scaleFfactor
                        }
                    }
                    Text {
                        id: messaage
                        anchors.left: parent.left
                        horizontalAlignment: Text.AlignLeft
                        width: delegateItem.width / 2
                        text: chatMessage.message
                        wrapMode: Text.WrapAnywhere
                        font.pixelSize: 25 * scaleFfactor
                    }
                }
            }
        }
    }


    Text {
        id: friendText
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 25 * scaleFfactor
        text: chatFriendName
        font.bold: true
        anchors.top: parent.top
        anchors.topMargin: 50
    }


    Row {
        id: row2
        anchors.left: parent.left
        anchors.verticalCenter: friendText.verticalCenter
        anchors.margins: 25 * scaleFfactor
        spacing: 5
        Rectangle {
            width: 40 * scaleFfactor
            height: width
            radius: height
            color: chatModel.state === ChatModel.Online ? "#70ed3a" : "#bbbbbb"
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 25 * scaleFfactor
            text: chatModel.state === ChatModel.Online ? qsTr("连接成功")　: qsTr("连接失败")
        }
    }

    Button {
        id: moreBt
        width: 80 * scaleFfactor
        height: width
        anchors.right: parent.right
        opacity: moreBt.pressed ? 0.5 : 1.0
        anchors.verticalCenter: friendText.verticalCenter
        background: Image {
            width: 64 * scaleFfactor
            height: width
            source: "qrc:/icons/more.png"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
        }
        onClicked: menu.open()
    }

    Menu {
        id: menu
        y: moreBt.y + 80 * scaleFfactor
        x: parent.width - 250 * scaleFfactor
        background: Rectangle{
            id: rect
            width: 200 * scaleFfactor
            height: 160 * scaleFfactor
            radius: 20 * scaleFfactor
            Column {
                MenuItem {
                    width: rect.width
                    height: 80 * scaleFfactor
                    Text {
                        anchors.centerIn: parent
                        color: "#e5170d"
                        text: qsTr("清空记录")
                        font.pixelSize: 25 * scaleFfactor
                    }
                    onClicked: {
                        chatModel.clear()
                        menu.close()
                    }
                }

                MenuItem {
                    width: rect.width
                    height: 80 * scaleFfactor
                    Text {
                        anchors.centerIn: parent
                        color: "black"
                        text: qsTr("更多帮助")
                        font.pixelSize: 25 * scaleFfactor
                    }
                    onClicked: {
                        menu.close()
                        dialog.open()
                    }
                }
            }
        }

    }
    Rectangle {
        id: inputRect
        color: "#d8d7d7"
        width: parent.width
        height: 80 * scaleFfactor
        y: inputPanel.y - height - 30
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 25 * scaleFfactor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 25 * scaleFfactor
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                radius: 4 * scaleFfactor
                Layout.preferredWidth: inputRect.width - 200 * scaleFfactor
                Layout.preferredHeight: inputRect.height - 10
                Flickable {
                    id: flickable
                    clip: true
                    anchors.fill: parent
                    contentHeight: textInput.height
                    TextInput {
                        id: textInput
                        width: parent.width
                        wrapMode: TextEdit.WrapAnywhere
                        font.pixelSize: scaleFfactor * 30
                        mouseSelectionMode: TextInput.SelectCharacters
                        selectByMouse: true
                        cursorVisible: textInput.focus
                        text: qsTr("正点原子官网：https://www.alientek.com")
                        onTextChanged: {
                            if (textInput.contentHeight > flickable.height)
                                flickable.contentY = textInput.contentHeight - flickable.height
                        }
                    }
                }
            }
            Button {
                Layout.preferredHeight: inputRect.height - 10
                Layout.preferredWidth: inputRect.height - 10
                opacity: 0.2
                background: Image {
                    width: 64
                    height: 64
                    anchors.centerIn: parent
                    source: "qrc:/icons/face.png"
                }
            }

            Button {
                id: sendBt
                Layout.preferredHeight: inputRect.height - 10
                Layout.preferredWidth: inputRect.height - 10
                opacity: sendBt.pressed ? 0.5 : 1.0
                background: Image {
                    width: 64
                    height: 64
                    anchors.centerIn: parent
                    source: "qrc:/icons/send.png"
                }
                onClicked: chatModel.sendMessage(textInput.text)
            }
        }
    }
}
