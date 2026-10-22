import QtQuick
import QtQuick.Shapes

Shape {
    id: mark

    property color ink

    width: 14
    height: 14
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        strokeColor: Qt.rgba(mark.ink.r, mark.ink.g, mark.ink.b, 0.45)
        strokeWidth: 1.2
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        PathSvg { path: "M12.2 10 A6 6 0 1 1 12.2 4" }
    }

    ShapePath {
        strokeColor: "transparent"
        fillColor: mark.ink
        PathSvg { path: "M13.7 4 A1.5 1.5 0 1 1 10.7 4 A1.5 1.5 0 1 1 13.7 4 Z" }
    }
}
