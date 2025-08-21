import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import com.alientek.qmlcomponents 1.0
import QtQuick.VirtualKeyboard 2.4
import QtQuick.VirtualKeyboard.Settings 1.2
Item {
    anchors.fill: parent
    property real scaleFfactor: window.width / 1024
    property string chatFriendName : qsTr("A35&M33 异核通信")
    property string contactInfo : qsTr("说明：A35与M33异核之间通过ttyRPMSG0虚拟串口交互。A35发送的消息内容到M33，然后M33立即返回相同的消息内容，直观展示了两者间的通信过程与效果。注意：每次最大字节为496Byte。")
    property string contacticon : "qrc:/icons/m33.png"

    ChatModel {
        id: chatModel
        portName: "ttyRPMSG0"
    }

    ChatWindow{
        anchors.fill: parent
    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height - scaleFfactor * 15
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 50
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    Binding {
        target: VirtualKeyboardSettings
        property: "activeLocales"
        value: ["zh_CN","en_US"]
    }
    Dialog {
        id: dialog
        modal: true
        property string icon: contacticon
        property string friendName: chatFriendName
        property string info: contactInfo
        width: 500 * scaleFfactor
        height: 400 * scaleFfactor
        anchors.centerIn: parent
        background: Rectangle {
            anchors.fill: parent
            radius: 10 * scaleFfactor
            border.width: 1
            border.color: "#DCDCDC"
        }
        Row {
            id: row
            spacing: 20
            anchors.left: parent.left
            Item {
                id: rectBg
                width: 80 * scaleFfactor
                height: width
                // color: "#c4c4c4"
                // radius: 5
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id: chatHeads
                    source: contacticon
                    sourceSize: Qt.size(rectBg.width, rectBg.height)
                    smooth: true
                    visible: false
                }

                Rectangle {
                    id: mask
                    anchors.fill: rectBg
                    visible: false
                    radius: 10
                }

                OpacityMask {
                    anchors.fill: rectBg
                    source: chatHeads
                    maskSource: mask
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                Text {
                    text: chatFriendName
                    font.pixelSize: 25 * scaleFfactor
                }
            }
        }
        Flickable {
            anchors.top: row.bottom
            anchors.topMargin: 20
            width: parent.width
            anchors.bottom: parent.bottom
            contentHeight: infoText.height + 1
            clip: true
            Text {
                id: infoText
                width: parent.width
                wrapMode: Text.WrapAnywhere
                text: contactInfo
                font.pixelSize: 25 * scaleFfactor
            }
        }
    }
}
