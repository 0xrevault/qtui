/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         WifiLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-08-29
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.15
import Connman 0.2
import QtQuick.Controls 2.15

Item {
    id: wifi
    property bool wifiChecked: networkTechnology.powered
    Component {
        id: wifiListConnectedDelegate
        CustomRectangle {
            radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
            id: rect
            radius: 10
            width: wifi.width - 10
            height: !networkService.name ? 0 : scaleFfactor  *  50
            color: mouseArea.pressed ? "#DCDCDC" : "white"
            MouseArea {
                enabled: networkService.name
                id: mouseArea
                anchors.fill: parent
            }
            ItemContent {}

            Image {
                anchors.left: parent.left
                anchors.leftMargin: scaleFfactor * 12.5
                anchors.verticalCenter: parent.verticalCenter
                width: scaleFfactor * 25
                height: width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/icons/wifi_connected_icon.png"
            }
        }
    }

    Component {
        id: wifiListActiveNotConnectedDelegate
        CustomRectangle {
            radiusCorners: if (modelActiveNotConnectedServices.count == 1)
                               Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop | Qt.AlignBottom
                           else if (index == 0)
                               Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop
                           else if (index == modelActiveNotConnectedServices.count - 1)
                               Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                           else 0
            id: rect
            radius: 10
            width: wifi.width - 10
            height: !networkService.name ? 0 : scaleFfactor  *  50
            color:  mouseArea.pressed ? "#DCDCDC" : "white"

            MouseArea {
                enabled: networkService.name
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    networkService.requestConnect()
                }
            }
            ItemContent {}
            Rectangle {
                visible: modelActiveNotConnectedServices.count !== 1 && index !== modelActiveNotConnectedServices.count - 1
                color: "#DCDCDC"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                anchors.leftMargin: 50 * scaleFfactor
            }
            Image {
                id: connect_process_icon
                visible: networkService !== undefined  ? networkService.connecting : false
                source: "qrc:/icons/wifi_process_icon.png"
                anchors.left: parent.left
                anchors.leftMargin: scaleFfactor * 12.5
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                width: scaleFfactor * 25
            }
            Timer {
                id: rotationAnimatorTimer
                running: connect_process_icon.visible
                repeat: true
                interval: 100
                onTriggered: connect_process_icon.rotation += 45
            }
        }
    }

    Component {
        id: wifiListNotActiveDelegate
        CustomRectangle {
            radiusCorners: if (modelNotActiveServices.count == 1)
                               Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop | Qt.AlignBottom
                           else if (index == 0)
                               Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop
                           else if (index == modelNotActiveServices.count - 1)
                               Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                           else 0
            id: rect
            radius: 10
            width: wifi.width - 10
            height: scaleFfactor  *  50
            color: mouseArea.pressed ? "#DCDCDC" : "white"
            MouseArea {
                enabled: true
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    if (networkService.securityType === NetworkService.SecurityNone)
                        networkService.requestConnect()
                    else {
                        ns.path = networkService.path
                        actionSheet.open()
                    }
                }
            }
            ItemContent {}
            Rectangle {
                visible: modelNotActiveServices.count !== 1 && index !== modelNotActiveServices.count - 1
                color: "#DCDCDC"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                anchors.leftMargin: 50 * scaleFfactor
            }
        }
    }


    Timer {
        id: autoConnectWifiTimer
        interval: 5000
        running: autoConnectSwitch.checked
        repeat: true
        onTriggered: {
            if (networkManager.connectingWifi)
                return
            if (ns.connecting)
                return
            if (actionSheet.opened)
                return
            if (modelConnectedServices.count === 0 && modelActiveNotConnectedServices.count !== 0) {
                if (!modelActiveNotConnectedServices.data(modelActiveNotConnectedServices.index(0, 0), 257).connecting) {
                    modelActiveNotConnectedServices.data(modelActiveNotConnectedServices.index(0, 0), 257).requestConnect()
                    ns.path = modelActiveNotConnectedServices.data(modelActiveNotConnectedServices.index(0, 0), 257).path
                }
            }
        }
    }

    Flickable {
        anchors.top: parent.top
        anchors.topMargin: scaleFfactor * 50
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: column.height + scaleFfactor *  30
        onFlickStarted: scrollBar.opacity = 1.0
        clip: false
        /*onFlickEnded: {
            scrollBar.opacity = 0.0
            if (!modelNotActiveServices.scanning) {
                modelNotActiveServices.requestScan()
            }
        }*/
        visibleArea.onYPositionChanged: {
            if (visibleArea.yPosition <= -0.05)
                if (!modelNotActiveServices.scanning) {
                    modelNotActiveServices.requestScan()
                }
        }
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
                color: scrollBar.hovered ? "#88101010" : "#33101010"
            }
            Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
        }
        Column {
            id: column
            Text {
                font.pixelSize: scaleFfactor * 20
                text: qsTr("无线局域网")
                color: "black"
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
            }
            Item {width: wifi.width - 10; height: 10 * scaleFfactor}

            ListView {
                interactive: false
                id: listViewConnected
                width: wifi.width
                height: contentHeight
                visible: true
                model: modelConnectedServices
                delegate: wifiListConnectedDelegate
                header: CustomRectangle {
                    radiusCorners: if (modelConnectedServices.count === 0)
                                       Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop | Qt.AlignBottom
                                   else
                                       Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop
                    radius: 10
                    height: scaleFfactor * 50
                    width: wifi.width - 10
                    Text {
                        font.pixelSize: scaleFfactor * 20
                        text: qsTr("无线局域网")
                        color: "black"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 50 * scaleFfactor
                    }
                    Rectangle {
                        visible: modelConnectedServices.count == 1
                        color: "#DCDCDC"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        anchors.leftMargin: 50 * scaleFfactor
                    }
                    CustomSwitch {
                        id: wlanSwitch
                        anchors.right: parent.right
                        anchors.rightMargin: scaleFfactor * 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: scaleFfactor * 50
                        height: scaleFfactor * 30
                        checked: wifiChecked
                        Component.onCompleted: wlanSwitch.checked = !networkManager.offlineMode
                        onCheckedChanged: networkTechnology.powered = checked
                    }
                }
            }

            ListView {
                interactive: false
                id: listViewActiveNotConnected
                width: wifi.width
                height: contentHeight
                visible: modelActiveNotConnectedServices.count !== 0
                model: modelActiveNotConnectedServices
                delegate: wifiListActiveNotConnectedDelegate
                header: Item {
                    width: parent.width
                    height: scaleFfactor * 50
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 15 * scaleFfactor
                        anchors.bottomMargin: 5 * scaleFfactor
                        text: qsTr("我的网络")
                        color: "#808A87"
                        font.pixelSize: scaleFfactor * 18
                    }
                }
            }

            ListView {
                interactive: false
                id: listViewNotActive
                width: wifi.width
                height: contentHeight
                visible: modelNotActiveServices.count !== 0
                model: modelNotActiveServices
                delegate: wifiListNotActiveDelegate
                header: Item {
                    width: wifi.width - 10
                    height: scaleFfactor * 50
                    Text {
                        id: netText
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 15 * scaleFfactor
                        anchors.bottomMargin: 5 * scaleFfactor
                        text: listViewNotActive.count　?　qsTr("其他网络")　:　qsTr("网络")
                        font.pixelSize: scaleFfactor * 18
                        color: "#808A87"
                    }
                    Image {
                        id: connect_process_icon
                        visible: modelNotActiveServices.scanning
                        source: "qrc:/icons/wifi_process_icon.png"
                        anchors.left: netText.right
                        anchors.leftMargin: 12.5 * scaleFfactor
                        anchors.verticalCenter: netText.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        width: scaleFfactor * 25
                    }
                    Timer {
                        id: rotationAnimatorTimer
                        running: connect_process_icon.visible
                        repeat: true
                        interval: 100
                        onTriggered: connect_process_icon.rotation += 45
                    }
                }
            }
            Item {
                height: scaleFfactor * 50
                width: wifi.width - 10
            }

            Rectangle {
                width: wifi.width - 10
                height: scaleFfactor * 50
                radius: 10
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: scaleFfactor * 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("自动加入热点")
                    font.pixelSize: scaleFfactor * 20
                }
                CustomSwitch {
                    id: autoConnectSwitch
                    anchors.right: parent.right
                    anchors.rightMargin: scaleFfactor * 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: scaleFfactor * 50
                    height: scaleFfactor * 30
                    checked: true
                }
            }

            Item {
                width: wifi.width
                height: scaleFfactor * 50
                Text {
                    text: qsTr("无线局域网可用时，如果没有连接网络，会从我的网络中首选第一个自动连接网络")
                    font.pixelSize: scaleFfactor * 15
                    color: "#808A87"
                    //anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: scaleFfactor * 10
                    anchors.rightMargin: 10
                    anchors.right: parent.right
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
    }

    Timer {
        id: autoreScanTimer
        interval: 60000
        repeat: true
        running: visible && wifiPageSwipeView.currentIndex === 0
        onTriggered: {
            if (modelNotActiveServices.scanning)
                console.log("scannig")
            else
                if (!modelNotActiveServices.scanning)
                    modelNotActiveServices.requestScan()
        }
    }
}
