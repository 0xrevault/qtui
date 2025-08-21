/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   weather
* @brief         WeatherLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-04-06
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.0
import QtQuick 2.12
import QtQuick.Layouts 1.12
import com.alientek.qmlcomponents 1.0
Rectangle {
    id: weatherBg
    color: "#6391cf" // #232730
    property real scaleFfactor: window.width / 720
    anchors.fill: parent

    NetworkPosition {
        id: networkPosition
        //Component.onCompleted: networkPosition.refreshPosition()
        interval: 30
    }

    WeatherForecast {
        id: weatherForecast
        //Component.onCompleted: weatherForecast.getWeatherForecast()
        interval: 30
    }

    Timer {
        repeat: false
        interval: 1000
        running: true
        onTriggered: {
            networkPosition.refreshPosition()
            weatherForecast.getWeatherForecast()
        }
    }

    function getDayName(day) {
        switch (day % 7){
        case 0:
            return qsTr("周日")
        case 1:
            return qsTr("周一")
        case 2:
            return qsTr("周二")
        case 3:
            return qsTr("周三")
        case 4:
            return qsTr("周四")
        case 5:
            return qsTr("周五")
        case 6:
            return qsTr("周六")
        }
    }


    /*Text {
        anchors.top: column.top
        anchors.topMargin: scaleFfactor * 90
        text: qsTr(weatherForecast.currentTemperature) + "° | " + weather.text
        font.pixelSize: scaleFfactor * 40
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: !temp.opacity
    }*/

    Column {
        visible: false
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: flickable.contentY > scaleFfactor * 50  ? scaleFfactor * 50 : flickable.contentY
        spacing: scaleFfactor * 10

        Text {
            id: position
            text: qsTr(networkPosition.position + networkPosition.area)
            font.pixelSize: scaleFfactor * 60
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
        }

        Text {
            id: temp
            text: qsTr(weatherForecast.currentTemperature) + "°"
            font.pixelSize: scaleFfactor * 150
            visible: false
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: ((scaleFfactor * 380 - flickable.contentY) / (scaleFfactor * 80)  - 1)
        }

        Text {
            id: weather
            text: qsTr("--")
            font.pixelSize: scaleFfactor * 40
            color: "white"
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: ((scaleFfactor * 250 - flickable.contentY) / (scaleFfactor * 60)  - 1)
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: scaleFfactor * 25
            Text {
                id: high_temp
                text: qsTr("--")
                font.pixelSize: scaleFfactor * 40
                visible: false
                color: "white"
                opacity: ((scaleFfactor * 180 - flickable.contentY) / (scaleFfactor * 60)  - 1)
            }

            Text {
                id: low_temp
                text: qsTr("--")
                visible: false
                font.pixelSize: scaleFfactor * 40
                color: "white"
                opacity: high_temp.opacity
            }

        }
    }

    ListModel {
        id: model
        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            tempVariations: 0
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            tempVariations: 0
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            tempVariations: 0
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            tempVariations: 0
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            tempVariations: 0
            item_color: "#78aaee"
        }

        ListElement {
            date: "--"
            weather: "--"
            low_temp: "--"
            high_temp: "--"
            tempVariations: 0
            item_color: "#78aaee"
        }
    }


    property string headerBgColor : "#78aaee"
    Connections {
        target: weatherForecast
        function onWeatherInfoChanged() {
            listView.visible = true
            //temp.visible = true
            low_temp.visible = true
            high_temp.visible = true
            weather.visible = true
            var dayName
            var time =  Number(Qt.formatDateTime(new Date(), "h" ))
            for (var i = 0; i < 8; i++) {  //获取8天天气，包括日期，天气类型，最低温与最高温
                var obj = model.get(i)
                if (i === 0)
                    obj.date = qsTr("昨天")
                else if (i === 1) {
                    obj.date = qsTr("今天")
                    var day = Qt.formatDateTime(new Date(), "dddd" )
                    if (day === "Sunday")
                        dayName = 0
                    else if (day === "Monday")
                        dayName = 1
                    else if (day === "Tuesday")
                        dayName = 2
                    else if (day === "Wednesday")
                        dayName = 3
                    else if (day === "Thursday")
                        dayName = 4
                    else if (day === "Friday")
                        dayName = 5
                    else if (day === "Saturday")
                        dayName = 6
                }
                else
                    obj.date = getDayName(dayName + i - 1)

                low_temp.text = "最低" + weatherForecast.weatherlowTemp(1) + "°"
                if (i === 1 && weatherForecast.weatherType(1) === "多云" || weatherForecast.weatherType(1) === "晴") {
                    if (time >= 18 || time <=  6)
                        obj.weather = "夜间" + weatherForecast.weatherType(i)
                    else
                        obj.weather = weatherForecast.weatherType(i)
                } else
                    obj.weather = weatherForecast.weatherType(i)
                if (time >= 18 || time <=  6)
                    obj.item_color = "#2a2e3a"
                else
                    obj.item_color = "#78aaee"
                headerBgColor = obj.item_color
                obj.low_temp = weatherForecast.weatherlowTemp(i)
                obj.high_temp = weatherForecast.weatherhighTemp(i)
                obj.tempVariations = Number(weatherForecast.weatherhighTemp(i)) - Number(weatherForecast.weatherlowTemp(i))
            }
            // today weather
            high_temp.text = "最高" + weatherForecast.weatherhighTemp(1) + "°"
            low_temp.text = "最低" + weatherForecast.weatherlowTemp(1) + "°"
            if (time >= 18 || time <=  6) {
                weather.text = "夜间" + weatherForecast.weatherType(1)
                weatherBg.color = "#232730"
                bottomRect.color = "#2a2e3a"
            } else {
                weather.text = weatherForecast.weatherType(1)
                weatherBg.color = "#6391cf"
                bottomRect.color = "#78aaee"
            }
        }
    }
    RowLayout {
        anchors.fill: parent
        Item {
            Layout.preferredWidth: parent.width / 3
            Layout.preferredHeight: parent.height
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: scaleFfactor * 25
                anchors.left: parent.left
                anchors.leftMargin: scaleFfactor * 25
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: scaleFfactor * 55
                color: headerBgColor
                radius: scaleFfactor * 25
                ColumnLayout {
                    anchors.fill: parent
                    Item {Layout.fillHeight: true}

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60 * scaleFfactor
                        Row {
                            spacing: 5
                            anchors.centerIn: parent
                            Text {
                                text: position.text
                                font.pixelSize: scaleFfactor * 30
                                color: "white"
                            }
                            Image {
                                source: "qrc:/icons/location.png"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100 * scaleFfactor
                        Image {
                            source: weather.text === "--" ? "file:///" + appCurrtentDir + "/resource/weather/" + "晴" : "file:///" + appCurrtentDir + "/resource/weather/" + weatherForecast.weatherType(1)
                            height: parent.height
                            width: parent.width
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50 * scaleFfactor
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text {
                                text: temp.text
                                font.pixelSize: scaleFfactor * 60
                                color: "white"
                            }
                            Text {
                                text: weather.text !== "--" ?  weatherForecast.weatherlowTemp(1) + "°/" : "__°/"
                                font.pixelSize: scaleFfactor * 25
                                color: "white"
                                anchors.bottom: parent.bottom
                            }
                            Text {
                                text: weather.text !== "--" ?  weatherForecast.weatherhighTemp(1) + "°" : "__°"
                                font.pixelSize: scaleFfactor * 25
                                color: "white"
                                anchors.bottom: parent.bottom
                            }
                        }
                    }
                    Item {Layout.fillHeight: true}
                }
            }
        }
        Flickable {
            id: flickable
            //width: parent.width
            Layout.preferredWidth: parent.width / 3 * 2
            contentHeight: listView.height + scaleFfactor * 51
            Layout.preferredHeight: parent.height

            Text {
                text: qsTr("请插入网线确保能连外网，\n初始化时更新一次天气数据,\n每30分钟更新一次")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 300 * scaleFfactor
                wrapMode: Text.WrapAnywhere
                anchors.topMargin: 150 * scaleFfactor
                horizontalAlignment: Qt.AlignHCenter
                color: "gray"
                font.pixelSize: 15 * scaleFfactor
            }

            ListView {
                id: listView
                anchors.horizontalCenter: parent.horizontalCenter
                model: model
                width: parent.width - scaleFfactor * 50
                height: listView.contentHeight
                anchors.top: parent.top
                anchors.topMargin: scaleFfactor * 10
                interactive : false
                visible: false
                header: CustomRectangle {
                    height: scaleFfactor * 60
                    width: listView.width
                    radiusCorners:  Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop
                    radius: scaleFfactor * 25
                    color: headerBgColor//"#2a2e3a"
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 20 * scaleFfactor
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 20

                        Image {
                            id: scheduleIcon
                            source: "qrc:/icons/schedule.png"
                            width: scaleFfactor * 30
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            id: forecastText
                            text: qsTr("8日天气预报")
                            font.pixelSize: scaleFfactor * 25
                            color: "#dddddd"
                        }
                    }
                }
                delegate: CustomRectangle {
                    id: customRect
                    height: scaleFfactor * 60
                    width: listView.width
                    radiusCorners: if ( index === listView.count - 1)
                                       Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                                   else
                                       0
                    radius: index === 7 ? scaleFfactor * 25 : 0
                    color: item_color//"#2a2e3a"

                    Rectangle {
                        height: 1
                        color: "#44dddddd"
                        width: listView.width - scaleFfactor * 50
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        //visible: index != 0
                    }
                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        height: parent.height
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        Text {
                            text: date
                            color: "white"
                            font.pixelSize: scaleFfactor * 25
                            Layout.preferredWidth: listView.width  / 5
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Item {
                            Layout.preferredWidth: listView.width  / 6
                            height: customRect.height / 2
                            Image {
                                anchors.centerIn: parent
                                width: parent.height
                                fillMode: Image.PreserveAspectFit
                                source: weather === "--" ? "" :"file:///" + appCurrtentDir + "/resource/weather/" + weather
                            }
                        }

                        Text {
                            text: low_temp + "°"
                            color: "white"
                            font.pixelSize: scaleFfactor * 25
                        }

                        Rectangle {
                            height: scaleFfactor * 10
                            radius: height / 2
                            color: "#554f6074"
                            id: parentRect
                            Layout.fillWidth: true
                            Rectangle {
                                height: parent.height
                                radius: parent.radius
                                anchors.leftMargin: (Number(low_temp) - weatherForecast.tempMin) * (parentRect.width / (weatherForecast.tempMax - weatherForecast.tempMin))
                                anchors.left: parent.left
                                width: tempVariations * (parentRect.width / (weatherForecast.tempMax - weatherForecast.tempMin))
                                clip: true
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: low_temp <= 15 ? "#286cfa" : "#cfd78e" }
                                    GradientStop { position: 1.0; color: high_temp >= 30 ? "#d3560a" : "#f2af2c" }
                                }
                            }
                        }

                        Text {
                            text: high_temp + "°"
                            color: "white"
                            font.pixelSize: scaleFfactor * 25
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomRect
        Rectangle {
            width: parent.width
            height: 1
            color: "gray"
        }
        anchors.bottom: parent.bottom
        width: parent.width
        height: scaleFfactor * 50
        color: weatherBg.color
        Image {
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: scaleFfactor * 10
            source: "qrc:/icons/location.png"
        }
    }
}
