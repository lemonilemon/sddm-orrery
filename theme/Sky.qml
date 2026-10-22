import QtQuick
import QtQuick.Shapes
import "sky.js" as SkyData

Item {
    id: sky

    property color ink
    readonly property var field: SkyData.stars(width, height)

    // The blog's t0–t7 twinkles: period and animation-delay, as phase offsets.
    property real p0
    property real p1
    property real p2
    property real p3
    property real p4
    property real p5
    property real p6
    property real p7

    NumberAnimation on p0 { from: 0; to: 1; duration: 4200; loops: Animation.Infinite }
    NumberAnimation on p1 { from: 1.3 / 5.6; to: 1 + 1.3 / 5.6; duration: 5600; loops: Animation.Infinite }
    NumberAnimation on p2 { from: 2.9 / 7.1; to: 1 + 2.9 / 7.1; duration: 7100; loops: Animation.Infinite }
    NumberAnimation on p3 { from: 4.1 / 8.8; to: 1 + 4.1 / 8.8; duration: 8800; loops: Animation.Infinite }
    NumberAnimation on p4 { from: 5.2 / 6.3; to: 1 + 5.2 / 6.3; duration: 6300; loops: Animation.Infinite }
    NumberAnimation on p5 { from: 0.7 / 9.7; to: 1 + 0.7 / 9.7; duration: 9700; loops: Animation.Infinite }
    NumberAnimation on p6 { from: 6.6 / 11.2; to: 1 + 6.6 / 11.2; duration: 11200; loops: Animation.Infinite }
    NumberAnimation on p7 { from: 3.4 / 5.1; to: 1 + 3.4 / 5.1; duration: 5100; loops: Animation.Infinite }

    function twinkle(phase) {
        return 0.6 + 0.4 * Math.cos(2 * Math.PI * sky["p" + phase]);
    }

    Repeater {
        model: sky.field.dots

        Rectangle {
            required property var modelData

            x: modelData.x - width / 2
            y: modelData.y - height / 2
            width: modelData.size
            height: modelData.size
            radius: width / 2
            color: Qt.rgba(sky.ink.r, sky.ink.g, sky.ink.b, modelData.alpha)
            opacity: sky.twinkle(modelData.phase)
        }
    }

    Repeater {
        model: sky.field.sparks

        Shape {
            required property var modelData

            x: modelData.x - 5
            y: modelData.y - 5
            width: 10
            height: 10
            scale: modelData.size / 10
            preferredRendererType: Shape.CurveRenderer
            opacity: sky.twinkle(modelData.phase)

            ShapePath {
                fillColor: Qt.rgba(sky.ink.r, sky.ink.g, sky.ink.b, modelData.alpha)
                strokeColor: "transparent"
                PathSvg { path: "M5 0 C5.5 3.7 6.3 4.5 10 5 C6.3 5.5 5.5 6.3 5 10 C4.5 6.3 3.7 5.5 0 5 C3.7 4.5 4.5 3.7 5 0 Z" }
            }
        }
    }
}
