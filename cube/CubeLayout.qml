/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         CubeLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-04
* @link          http://www.alientek.com
*******************************************************************/
import QtQuick 2.12
import QtQuick3D 1.15
Item {
    anchors.fill: parent

    Image {
        id: image
        visible: false
        source: "qrc:/image/default.jpg"
    }

    View3D {
        id: view
        anchors.fill: parent
        camera: camera
        renderMode: View3D.Overlay

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 100, 200)
            eulerRotation.x: -30
        }

        DirectionalLight {
            eulerRotation.x: -30
        }

        Model {
            //! [3dcube]
            id: cube
            visible: true
            position: Qt.vector3d(0, 0, 0)
            source: "#Cube"
            materials: [ DefaultMaterial {
                    diffuseMap: Texture {
                        id: texture
                        sourceItem: image
                    }
                }
            ]
            eulerRotation.y: 90
            //! [3dcube]

            SequentialAnimation on eulerRotation {
                loops: Animation.Infinite
                PropertyAnimation {
                    duration: 5000
                    from: Qt.vector3d(0, 0, 0)
                    to: Qt.vector3d(360, 0, 360)
                }
            }
        }
    }
}
