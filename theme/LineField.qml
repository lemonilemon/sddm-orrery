import QtQuick

FocusScope {
    id: field

    property string label
    property alias text: input.text
    property bool password: false
    property bool alert: false
    property real unit: 1
    property color ink
    property color muted
    property color rule
    property string textFont
    property string labelFont

    signal accepted

    implicitHeight: 44 * unit

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: input.forceActiveFocus()
    }

    Text {
        id: caption
        width: 96 * field.unit
        anchors.baseline: input.baseline
        text: field.label.toUpperCase()
        color: field.muted
        font.family: field.labelFont
        font.pixelSize: 12.5 * field.unit
        font.letterSpacing: 1.5 * field.unit
    }

    TextInput {
        id: input
        anchors.left: caption.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        focus: true
        clip: true
        color: field.ink
        selectionColor: "#3a3524"
        selectedTextColor: field.ink
        selectByMouse: true
        font.family: field.textFont
        font.pixelSize: 18 * field.unit
        font.letterSpacing: field.password ? 2.5 * field.unit : 0
        echoMode: field.password ? TextInput.Password : TextInput.Normal
        passwordCharacter: "•"
        passwordMaskDelay: 0
        onAccepted: field.accepted()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: input.activeFocus || field.alert ? field.ink : field.rule
    }
}
