/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         DashBoard.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-07-18
* @link          http://www.openedv.com/forum.php
*******************************************************************/
import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.15
import QtQuick.Window 2.12
Item {
    id: dashboardItem
    property real scaleFacter: dashboardItem.width / 640 * (Screen.desktopAvailableWidth === 1920 ? 1.3 : (Screen.desktopAvailableWidth === 1280 ? 1.1 : (Screen.desktopAvailableWidth === 800 ? 0.8 : 1)))
    property int  dashboarMaximumValue: 100
    property bool accelerating: false

    width: 640
    height: width
    Image {
        id: name
        anchors.centerIn: parent
        width: 550 * scaleFacter
        height: width
        source: "qrc:/images/dashboardbg1.png"
    }

    /*Canvas {
        id: canvas1
        anchors.centerIn: parent
        width: 300 * scaleFacter
        height: width
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            // ctx.createRadialGradient(x0, y0, r0, x1, y1, r1)
            var grad = ctx.createRadialGradient(canvas1.width / 2, canvas1.height / 2, 10, canvas1.width / 2, canvas1.height / 2, 130 * scaleFacter)
            grad.addColorStop(0, "transparent")
            grad.addColorStop(0.4, "transparent")
            grad.addColorStop(0.8, "#25556d")
            grad.addColorStop(0.9, "#25556d")
            grad.addColorStop(1, "transparent")
            ctx.fillStyle = grad
            ctx.fillRect(0, 0, width, height)
            ctx.stroke()
        }
    }*/

    property real minimumValue: 0
    property real maximumValue: 130 * (circularGauge.maximumValue / 100)//116
    property real currentValue: 0
    //property real maxValue: 100

    onCurrentValueChanged: canvas3.requestPaint()

    Canvas {
        id: canvas3
        width: 640 * scaleFacter
        height: width
        antialiasing: true
        anchors.centerIn: parent

        property real centerWidth: width / 2
        property real centerHeight: height / 2
        property real radius: width / 5 // 半径

        // this is the angle that splits the circle in two arcs
        // first arc is drawn from 0 radians to angle radians
        // second arc is angle radians to 2*PI radians
        property real angle: (currentValue - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI

        // we want both circle to start / end at 12 o'clock
        // without this offset we would start / end at 9 o'clock
        property real angleOffset: -Math.PI / 2
        signal clicked()

        onPaint: {
            var ctx = getContext("2d")
            ctx.save()
            ctx.clearRect(0, 0, canvas3.width, canvas3.height)

            //background arc
            ctx.beginPath()
            ctx.lineWidth = 30 * scaleFacter
            ctx.strokeStyle = "#123e48"
            ctx.arc(canvas3.centerWidth,
                    canvas3.centerHeight,
                    canvas3.radius,
                    2.3,
                    7.1)
            ctx.stroke()

            //progress arc
            ctx.beginPath()
            ctx.lineWidth = 30 * scaleFacter
            var grd = ctx.createLinearGradient(0, 0, 640, 0)
            grd.addColorStop(0, "#57c2fd")
            grd.addColorStop(0.5, "#63fbab")
            grd.addColorStop(1.0, "#5dfbd4")
            ctx.strokeStyle = grd
            ctx.fillStyle = grd

            ctx.arc(canvas3.centerWidth,
                    canvas3.centerHeight,
                    canvas3.radius,
                    2.3,
                    2.3 + canvas3.angle)
            ctx.stroke()
            ctx.restore()
        }
    }

    Text {
        id: txt_progress
        anchors.centerIn: parent

        font.pixelSize: 80 * scaleFacter
        font.bold: true
        text: Math.round(circularGauge.value)
        color: "white"
    }

    CircularGauge {
        id: circularGauge
        width: 400 * scaleFacter
        height: width
        tickmarksVisible: false
        maximumValue: dashboarMaximumValue
        value: accelerating ? maximumValue : 0
        anchors.centerIn: parent

        Keys.onSpacePressed: accelerating = true
        Keys.onReleased: {
            if (event.key === Qt.Key_Space) {
                accelerating = false
                event.accepted = true
            }
        }
        onValueChanged: {
            currentValue = Math.round(value)
        }

        Component.onCompleted: forceActiveFocus()

        Behavior on value {
            NumberAnimation {
                duration: 1000
            }
        }
        style: CircularGaugeStyle {
            minimumValueAngle: -140
            maximumValueAngle: 140
            needle: Rectangle {
                radius: 2 * scaleFacter
                y: -outerRadius * 0.2
                implicitWidth: outerRadius * 0.03
                implicitHeight: outerRadius * 0.52
                antialiasing: true
                //color: "#fef272"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#72e6eb" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            foreground: Item {
            }
        }
    }
}
