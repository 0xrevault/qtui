/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   fileview
* @brief         FileViewLayout.qml
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-11-25
*******************************************************************/
import QtQuick 2.9
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls 2.5
import com.alientek.qmlcomponents 1.0
Rectangle {
    id : fileView
    anchors.fill: parent
    property string folderPathName: "file:/"
    property string currtentPathName
    property int folderNavigationItemCount: 0
    property real scaleFacter: parent.width / 1024

    FolderPathList {
        id: folderPathList
        mediaPath: "/run/media"
        onCurrentIndexChanged: {
            if (currentIndex < 0)
                return
            folderNavigation.model.clear()
            fileView.folderPathName = "file:" + folderPathList.currentMediaPath
            fileView.currtentPathName = folderPathList.currentMediaPath
            var components = folderPathList.splitPath(folderPathList.currentMediaPath)
            for (var i = 0; i < components.length; ++i) {
                folderNavigation.model.insert(folderNavigation.model.count, {"currtentPathName": components[i],
                                                  "folderPathName": "file:" + components[i]})
            }
            fileView.folderNavigationItemCount = folderNavigation.count
            folderNavigation.currentIndex = folderNavigation.count - 1
        }
    }

    Component.onCompleted: {
        folderNavigation.model.insert(folderNavigation.model.count, {"currtentPathName": "/",
                                          "folderPathName": "file:/"})
        fileView.folderNavigationItemCount = folderNavigation.count
        folderNavigation.currentIndex = folderNavigation.count - 1
    }
    Rectangle {
        id: leftSideRect
        height: parent.height
        width: parent.width / 4
        color: "#dcdcdc"
        ListView {
            id: folderPathListView
            model: folderPathList
            anchors.top: parent.top
            anchors.topMargin: 80 * scaleFacter
            width: parent.width - 50 * scaleFacter
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            spacing: 10
            currentIndex: folderPathList.currentIndex
            delegate: Rectangle {
                width: folderPathListView.width
                height: 50 * scaleFacter
                color: ListView.isCurrentItem ? "white" : "transparent"
                radius: 10
                MouseArea {
                    anchors.fill: parent
                    onClicked: folderPathList.currentIndex = index
                }
                Image {
                    anchors.left: parent.left
                    width: 30 * scaleFacter
                    height: 30 * scaleFacter
                    id: mediaTypeIcon
                    source:  if (mediaInfo.mediaType === FolderPathList.MMC)
                                 return "qrc:/icons/harddisk.png"
                             else if (mediaInfo.mediaType === FolderPathList.USB)
                                 return "qrc:/icons/usb.png"
                             else
                                 return "qrc:/icons/otherfolder.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    anchors.left: mediaTypeIcon.right
                    anchors.leftMargin: 2
                    text: mediaInfo.path
                    font.pixelSize: 20 * scaleFacter
                    anchors.right: parent.right
                    elide: Text.ElideLeft
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            header: Item {
                width: parent.width
                height: 50 * scaleFacter
                Text {
                    color: "gray"
                    text: qsTr("Locations")
                    font.pixelSize: 25 * scaleFacter
                    font.bold: true
                }
            }
        }
    }
    Rectangle {
        height: 120 * scaleFacter
        anchors.left: leftSideRect.right
        anchors.right: parent.right
        color: "#f5f5f5"

        ListView {
            id: folderNavigation
            anchors.verticalCenter: parent.verticalCenter
            width: fileView.width
            height: 60 * scaleFacter
            clip: true
            spacing: 3
            orientation : ListView.Horizontal
            delegate: Rectangle{
                radius: 10
                width: pathText.contentWidth * 1.2 < 60 * scaleFacter ? 60 * scaleFacter : pathText.contentWidth * 1.2
                height: 60 * scaleFacter
                color: "#e8e2e6"
                Text{
                    id: pathText
                    color: parent.ListView.isCurrentItem ? "black": "gray"
                    text: currtentPathName
                    font.pixelSize: 25 * scaleFacter
                    anchors.centerIn: parent
                    font.bold: parent.ListView.isCurrentItem ? true : false
                }
                Text {
                    id: textMyPath
                    visible: false
                    text: folderPathName
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        fileView.folderPathName = folderNavigation.model.get(index).folderPathName
                        if (index < folderNavigation.count - 1)
                            for(var i = index;  i < fileView.folderNavigationItemCount -1 ; i++ ){
                                listmodel.remove(index+1)
                            }
                        fileView.folderNavigationItemCount = folderNavigation.count
                    }
                }
            }
            model:ListModel{
                id: listmodel
            }
        }
    }


    function insertItem(){
        folderNavigation.model.insert(folderNavigation.model.count, {"currtentPathName" : fileView.currtentPathName, "folderPathName": fileView.folderPathName})
        fileView.folderNavigationItemCount = folderNavigation.count
        folderNavigation.currentIndex = folderNavigation.count -1
    }

    GridView {
        id: listFileView
        cellWidth: listFileView.width / 5
        cellHeight: listFileView.width / 5
        snapMode: GridView.SnapOneRow
        anchors {
            bottom: parent.bottom
            bottomMargin: 4
            right: parent.right
            left: parent.left
            leftMargin: parent.width / 4
            top: parent.top
            topMargin: 120 * scaleFacter
        }
        onFlickStarted: scrollBar.opacity = 1.0
        onFlickEnded: scrollBar.opacity = 0.5

        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            width: 10
            opacity: 0.0
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
                color: scrollBar.hovered ? "#101010" : "#80101010"
            }
            Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.Linear } }
        }

        clip: true
        delegate: Item{
            width: listFileView.cellWidth
            height: width
            Image {
                id: folderIcon
                anchors.centerIn: parent
                width: 100 * scaleFacter
                height: width
                source: folderModel.get(index, "fileIsDir") ? "qrc:/icons/folder.png"  : "qrc:/icons/file.png"
            }

            Text {
                id: textfileName
                text: fileName
                width: 100 * scaleFacter
                color: "black"
                font.pixelSize: 20 * scaleFacter
                font.bold: true
                anchors.top: folderIcon.bottom
                anchors.horizontalCenter: folderIcon.horizontalCenter
                anchors.topMargin: 5
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                visible: false
                id: textModify
                text: fileModified
                anchors.top: textfileName.bottom
                anchors.horizontalCenter: textfileName.horizontalCenter
                color: "black"
                font.bold: true
                font.pixelSize: 13 * scaleFacter
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if(folderModel.isFolder(index)){
                        fileView.folderPathName = folderModel.get(index, "fileURL")
                        fileView.currtentPathName = folderModel.get(index, "fileName")
                        insertItem()
                    } else {
                        warningDialog.open()
                        globalFileName.text = folderModel.get(index, "fileName")
                        globalFilePath.text = "文件路径:" + folderModel.get(index, "filePath")
                        globalFileSize.text = "文件大小:" + folderModel.get(index, "fileSize") + "b"
                        globalFilefileModified.text = "修改日期:" + folderModel.get(index, "fileModified")
                        /*var size = folderModel.get(index, "fileSize")
                        if (size < 10000) {
                            switch (folderModel.get(index, "fileSuffix")) {
                            case "txt":
                            case "sh":
                            case "conf":
                            case "cpp":
                            case "c":
                            case "h":
                            case "sh":
                            case "local":
                            case "lrc":
                            case "blacklist":
                            case "py":
                                break
                            default:
                                warningDialog.open()
                                return;
                            }
                            dialog.open()
                            //myFile.source = folderModel.get(index, "filePath")
                            //myText.text = myFile.read()
                        } else {
                            //warningDialog.open()
                        }*/
                    }
                }
            }
        }
        model: FolderListModel{
            id: folderModel
            objectName: "folderModel"
            showDirs: true
            showFiles: true
            showDirsFirst: true
            showDotAndDotDot: false
            nameFilters: ["*"]
            folder: fileView.folderPathName
            onFolderChanged: {

            }
        }
    }

    Dialog {
        id: warningDialog
        modal: true
        width: parent.width / 2
        height: parent.height / 2
        anchors.centerIn: parent
        //standardButtons: Dialog.Close
        background: Rectangle {
            anchors.fill: parent
            color: "#f8f8ff"
            radius: 20 * scaleFacter
            CustomRectangle {
                width: parent.width
                height: 50 * scaleFacter
                color: "#e4e1e4"
                radius: 20 * scaleFacter
                radiusCorners: Qt.AlignLeft | Qt.AlignRight | Qt.AlignTop
                Text {
                    width: parent.width / 2
                    id: globalFileName
                    anchors.centerIn: parent
                    color: "black"
                    font.bold: true
                    font.pixelSize: 25 * scaleFacter
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Flickable {
                width: parent.width
                height: parent.height - 100 * scaleFacter
                anchors.centerIn: parent
                contentHeight: column.height
                clip: true
                Column {
                    id : column
                    width: parent.width
                    Text {
                        color: "black"
                        font.pixelSize: 25 * scaleFacter
                        width: parent.width - 10
                        text: qsTr("文件名称:" + globalFileName.text)
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        width: parent.width - 10
                        id: globalFilePath
                        color: "black"
                        font.pixelSize: 25 * scaleFacter
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        width: parent.width - 10
                        id: globalFileSize
                        color: "black"
                        font.pixelSize: 25 * scaleFacter
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        width: parent.width - 10
                        id: globalFilefileModified
                        color: "black"
                        font.pixelSize: 25 * scaleFacter
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }
            Button {
                id: okBt
                anchors.bottom: parent.bottom
                height: 50 * scaleFacter
                width: parent.width
                background: CustomRectangle {
                    color: okBt.pressed ? "#e4e1e4" :  "#1e90ff"
                    anchors.fill: parent
                    radius: 20 * scaleFacter
                    radiusCorners:  Qt.AlignLeft | Qt.AlignRight | Qt.AlignBottom
                }
                Text {
                    anchors.centerIn: parent
                    text: qsTr("确定")
                    font.bold: true
                    color: okBt.pressed ? "#1e90ff" : "white"
                    font.pixelSize: 25 * scaleFacter
                }
                onClicked: {
                    warningDialog.close()
                }
            }
        }
    }
}

