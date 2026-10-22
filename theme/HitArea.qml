import QtQuick

Item {
    id: area

    readonly property bool lit: pointer.containsMouse || activeFocus

    signal triggered

    activeFocusOnTab: true

    Keys.onPressed: event => {
        if (event.key !== Qt.Key_Space && event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter)
            return;
        event.accepted = true;
        if (!event.isAutoRepeat)
            area.triggered();
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: area.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: area.triggered()
    }
}
