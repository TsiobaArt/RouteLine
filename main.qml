import QtQuick 2.12
import QtQuick.Window 2.15
import QtPositioning 5.15
import QtLocation 5.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import QtQuick.Controls 2.15
import Qt.labs.qmlmodels 1.0
import Qt.labs.platform 1.0
import QtGraphicalEffects 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Styles 1.4

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ListModel { id: modelRoute }

    function paintCanvas (){
      canvas.requestPaint()
    }
    Map {
        id: map
        width: parent.width
        height: parent.height
        zoomLevel: 12
        copyrightsVisible: false
        plugin: Plugin { name: "mapboxgl" }
        center: QtPositioning.coordinate(50.527887655789385, 30.614663315058465)
        anchors.centerIn: parent

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onDoubleClicked: {
                var coordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                modelRoute.append({"latitude": coordinate.latitude, "longitude" : coordinate.longitude })
                canvas.requestPaint();
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
             Component.onCompleted:  canvas.requestPaint()
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.beginPath();
                ctx.lineWidth = 2;
                ctx.strokeStyle = "black";
                ctx.setLineDash([3, 5]);

                for (var i = 0; i < modelRoute.count; ++i) {
                    var coord = modelRoute.get(i);
                    var point = map.fromCoordinate(QtPositioning.coordinate(coord.latitude, coord.longitude), false);

                    if (i === 0) {
                        ctx.moveTo(point.x, point.y);
                    } else {
                        ctx.lineTo(point.x, point.y);
                    }
                }
                ctx.stroke();
            }
        }
        MapItemView {
            model: modelRoute

            delegate : MapQuickItem {
                id: item
                anchorPoint.x: recSourceItem.width / 2
                anchorPoint.y: recSourceItem.height / 2
                coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                onXChanged: paintCanvas()
                onYChanged: paintCanvas()
                sourceItem: Rectangle {
                    id: recSourceItem
                    width: 24
                    height: 24
                    radius: 24
                    color: "black"

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 18
                        anchors.centerIn: parent
                        color: "white"
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 12
                            anchors.centerIn: parent
                            color: "violet"
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 8
                                anchors.centerIn: parent
                                color: "white"
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    hoverEnabled: true
                    onReleased:  {
                     }
                    onPositionChanged: {
                        var coordinate =  parent.coordinate
                        modelRoute.set(index, {"latitude" : coordinate.latitude, "longitude" : coordinate.longitude})
                        canvas.requestPaint();

                    }
                }
            }
        }

    }
}
