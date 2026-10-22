import QtQuick
import QtQuick.Shapes

Item {
    id: button

    property string label
    property string icon
    property real unit: 1
    property color ink
    property color muted
    property string labelFont
    readonly property color tone: area.containsMouse ? ink : muted

    signal clicked

    width: 76 * unit
    height: caption.y + caption.height

    Shape {
        x: (button.width - width) / 2
        y: (44 * button.unit - height) / 2
        width: 24
        height: 24
        scale: 0.75 * button.unit
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: button.tone
            strokeWidth: 1.5
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: button.icon }
        }
    }

    Text {
        id: caption
        y: 50 * button.unit
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: button.label.toUpperCase()
        color: button.tone
        font.family: button.labelFont
        font.pixelSize: 11 * button.unit
        font.letterSpacing: 1.1 * button.unit
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
