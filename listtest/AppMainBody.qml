import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    anchors.fill: parent
    // Target ~10 items per screen: each item takes 1/10 of the view height
    property int itemHeight: Math.max(56, Math.floor(height / 10))
    property int batchSize: 200
    property int maxItems: 100000000
    property int loadedCount: 0
    property int triggerThreshold: item_listView.height * 2

    Rectangle {
        anchors.fill: parent
        color: "white"
    }

    ListModel {
        id: listModel
    }

    function populate(initial) {
        var start = loadedCount;
        var count = batchSize;
        if (loadedCount >= maxItems)
            return;
        for (var i = 0; i < count; ++i) {
            var n = start + i;
            if (n >= maxItems)
                break;
            listModel.append({
                idx: n,
                title: "Item " + n,
                subtitle: "This is a long row for performance testing " + n
            });
        }
        loadedCount += count;
    }

    function ensureBuffer() {
        // Top
        if (item_listView.contentY < triggerThreshold)
        // optional: prepend older items if needed
        {}
        // Bottom
        if (item_listView.contentHeight - (item_listView.contentY + item_listView.height) < triggerThreshold) {
            populate(false);
        }
    }

    Component.onCompleted: {
        populate(true);
    }

    ListView {
        id: item_listView
        anchors.fill: parent
        model: listModel
        clip: true
        cacheBuffer: height * 4
        boundsBehavior: Flickable.StopAtBounds
        interactive: true
        pressDelay: 0
        maximumFlickVelocity: 4000
        flickDeceleration: 6000
        delegate: ItemDelegate {
            width: ListView.view.width
            height: itemHeight
            text: title
            font.pixelSize: Math.max(20, width / 32)
            contentItem: Row {
                spacing: 12
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                Rectangle {
                    width: itemHeight * 0.6
                    height: width
                    radius: width / 5
                    color: idx % 2 ? "#e0f7fa" : "#ffe0b2"
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: title
                        font.bold: true
                        font.pixelSize: Math.max(20, width / 32)
                    }
                    Text {
                        text: subtitle
                        color: "#666666"
                        elide: Text.ElideRight
                        font.pixelSize: Math.max(16, width / 36)
                    }
                }
            }
            onClicked:
            // no-op
            {}
        }
        onContentYChanged: ensureBuffer()
        onMovementEnded: ensureBuffer()
    }

    // Simple overlay counters
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        color: "#66000000"
        radius: 6
        border.color: "#22ffffff"
        border.width: 1
        z: 10
        Row {
            anchors.margins: 8
            anchors.fill: parent
            spacing: 10
            Text {
                text: "Items: " + loadedCount
                color: "white"
            }
            Text {
                text: "ContentY: " + Math.round(item_listView.contentY)
                color: "white"
            }
            Text {
                text: "FPS overlay在桌面有"
                visible: false
            }
        }
    }
}
