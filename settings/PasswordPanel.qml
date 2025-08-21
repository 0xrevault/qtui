/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         PasswordPanel.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-02
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.15
Rectangle {
    anchors.top: parent.top
    anchors.topMargin: scaleFfactor * 50
    width: parent.width
    height: parent.height
    color: "#f0f0f0"
    radius: scaleFfactor * 20
    focus: true

    Text {
        id: essidName
        text: qsTr("请输入") + "“" + ns.name + "”" + qsTr("的密码");
        anchors.top: parent.top
        anchors.topMargin: scaleFfactor * 20
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: scaleFfactor * 20
    }

    Row {
        id: row1
        anchors.top: parent.top
        anchors.topMargin: scaleFfactor * 50
        width: parent.width - scaleFfactor * 60
        anchors.horizontalCenter: parent.horizontalCenter
        height: scaleFfactor * 50

        Button {
            id: cancelBt
            width: parent.width / 3
            height: parent.height
            focusPolicy: Qt.NoFocus
            background: Item { }
            Text {
                id: cancelTextTitile
                text: qsTr("取消")
                font.pixelSize: scaleFfactor * 20
                color: Qt.rgba(0, 0.5, 1, 1)
                anchors.fill: parent
                opacity: cancelBt.pressed ? 0.5 : 1.0
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
            }
            onClicked: { actionSheet.close() }
        }

        Text {
            id: inputTextTitile
            text: qsTr("输入密码")
            font.pixelSize: 20 * scaleFfactor
            font.weight: Font.Medium
            width: parent.width / 3
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Button {
            id: joinBt
            width: parent.width / 3
            height: parent.height
            focusPolicy: Qt.NoFocus
            background: Item { }
            Text {
                id: joinTextTitile
                text: qsTr("加入")
                font.pixelSize: scaleFfactor * 20
                color: textInput.length >= 8 ?  Qt.rgba(0, 0.5, 1, 1) : "gray"
                anchors.fill: parent
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }
            onClicked: {
                if (textInput.length >= 8) {
                    wifiServicesSettings.passphrase = textInput.text
                    wifiServicesSettings.writeServicesConfig()
                    actionSheet.close()
                    ns.requestConnect()
                    textInput.focus = false
                }
            }
        }
    }

    Rectangle {
        anchors.top: row1.bottom
        anchors.topMargin: 10 * scaleFfactor
        height: scaleFfactor * 50
        anchors.left: parent.left
        anchors.leftMargin: scaleFfactor * 30
        anchors.right: parent.right
        anchors.rightMargin: scaleFfactor * 30
        radius: 10
        Row {
            id: row2
            anchors.fill: parent
            Item {
                width: 15 * scaleFfactor
                height: parent.height
            }
            Text {
                id: passwordTextTitle
                text: qsTr("密码")
                width: scaleFfactor * 100
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: scaleFfactor * 20
                focus: false
            }

            TextInput {
                id: textInput
                width: parent.width - scaleFfactor * 200
                height: parent.height
                font.pixelSize: scaleFfactor * 30
                verticalAlignment: Text.AlignVCenter
                inputMethodHints: Qt.ImhHiddenText
                echoMode:TextInput.Password
                passwordMaskDelay: 2000
                cursorVisible: true
            }

            Button {
                id: eyesBt
                width: scaleFfactor * 100
                height: parent.height
                checkable: true
                focusPolicy: Qt.NoFocus
                background: Image {
                    width: scaleFfactor * 32
                    height: width
                    anchors.centerIn: parent
                    source: eyesBt.checked ? "qrc:/icons/password_eyes_open.png" : "qrc:/icons/password_eyes_close.png"
                }
                onCheckedChanged: {
                    if (!eyesBt.checked)
                        textInput.echoMode = TextInput.Password
                    else {
                        textInput.echoMode = TextInput.PasswordEchoOnEdit
                        textInput.echoMode = TextInput.Normal
                    }
                }
            }
        }
    }

    Connections {
        target: appMainBody
        function onVisibleChanged() {
            if (!visible)
                textInput.focus = false
        }
    }

    Connections {
        target: actionSheet
        function onOpenedChanged() {
            if (!actionSheet.opened)
                textInput.focus = false
        }
    }
}
