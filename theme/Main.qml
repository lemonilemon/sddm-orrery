import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    readonly property real unit: Math.min(width / 1920, height / 1080)
    readonly property color ink: "#e8e6df"
    readonly property color body: "#c4c2bb"
    readonly property color muted: "#9a9a93"
    readonly property color faint: "#7d828a"
    readonly property color rule: "#262a31"
    readonly property color ruleStrong: "#454b55"
    readonly property string textFont: config.Font
    readonly property string labelFont: config.LabelFont
    readonly property bool showAllPowerButtons: String(config.ShowAllPowerButtons) === "true"

    property date now: new Date()
    property bool failed: false
    property int sessionIndex: sessionModel.lastIndex
    readonly property string sessionName: sessions.count > 0 && sessions.itemAt(sessionIndex)
        ? sessions.itemAt(sessionIndex).name : ""
    readonly property string layoutName: keyboard.layouts.length > 0 && keyboard.layouts[keyboard.currentLayout]
        ? keyboard.layouts[keyboard.currentLayout].shortName : ""

    function login() {
        failed = false;
        sddm.login(userField.text, passwordField.text, sessionIndex);
    }

    width: 1920
    height: 1080
    color: "#0e1014"

    Component.onCompleted: passwordField.forceActiveFocus()

    Connections {
        target: sddm

        function onLoginFailed() {
            root.failed = true;
            passwordField.text = "";
            passwordField.forceActiveFocus();
            shake.restart();
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }

    Repeater {
        id: sessions
        model: sessionModel
        delegate: Item {
            required property string name
        }
    }

    Repeater {
        id: users
        model: userModel
        delegate: Item {
            required property string name
        }
    }

    Item {
        id: backdrop
        anchors.fill: parent

        Sky {
            anchors.fill: parent
            ink: root.ink
        }

        Orrery {
            id: orrery
            anchors.fill: parent
            ink: root.ink
            unit: root.unit
            centerX: parent.width * 0.6458
            centerY: parent.height / 2
            auPixels: 210 * root.unit
        }
    }

    Item {
        id: strip
        x: Math.round(parent.width * 0.3)
        width: Math.round(parent.width * 0.4)
        height: parent.height

        ShaderEffectSource {
            id: behind
            anchors.fill: parent
            sourceItem: orrery
            sourceRect: Qt.rect(strip.x, strip.y, strip.width, strip.height)
            visible: false
        }

        Rectangle {
            anchors.fill: parent
            color: root.color
        }

        MultiEffect {
            anchors.fill: parent
            source: behind
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 24
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(14 / 255, 16 / 255, 20 / 255, 0.45)
        }

        Rectangle {
            width: 1
            height: parent.height
            color: root.rule
        }

        Rectangle {
            x: parent.width - 1
            width: 1
            height: parent.height
            color: root.rule
        }

        MouseArea {
            anchors.fill: parent
            onClicked: passwordField.forceActiveFocus()
        }

        Text {
            y: Math.round(parent.height * 0.163)
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatTime(root.now, "HH:mm")
            color: root.ink
            font.family: root.textFont
            font.weight: Font.Medium
            font.pixelSize: 132 * root.unit
            font.letterSpacing: -4 * root.unit
            font.features: ({ "tnum": 1 })
        }

        Text {
            y: Math.round(parent.height * 0.309)
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.now.toLocaleDateString(Qt.locale("en_US"), "dddd, d MMMM")
            color: root.body
            font.family: root.textFont
            font.pixelSize: 22 * root.unit
        }

        Column {
            x: Math.round((parent.width - width) / 2)
            y: Math.round(parent.height * 0.537)
            width: 384 * root.unit
            spacing: 16 * root.unit

            LineField {
                id: userField
                width: parent.width
                label: "User"
                text: userModel.lastUser || (users.count > 0 ? users.itemAt(0).name : "")
                unit: root.unit
                ink: root.ink
                muted: root.muted
                rule: root.ruleStrong
                textFont: root.textFont
                labelFont: root.labelFont
                onAccepted: passwordField.forceActiveFocus()
            }

            LineField {
                id: passwordField
                width: parent.width
                label: "Password"
                password: true
                alert: root.failed
                unit: root.unit
                ink: root.ink
                muted: root.muted
                rule: root.ruleStrong
                textFont: root.textFont
                labelFont: root.labelFont
                onAccepted: root.login()
                onTextChanged: if (text.length > 0) root.failed = false

                transform: Translate { id: nudge }
            }

            Text {
                width: parent.width
                height: 19 * root.unit
                text: root.failed ? "Wrong password. Try again." : keyboard.capsLock ? "Caps Lock is on." : ""
                color: root.ink
                font.family: root.labelFont
                font.pixelSize: 12.5 * root.unit
                font.letterSpacing: 0.5 * root.unit
            }

            Item {
                width: parent.width
                height: 52 * root.unit

                Rectangle {
                    y: 8 * root.unit
                    width: parent.width
                    height: 44 * root.unit
                    color: "transparent"
                    radius: 2 * root.unit
                    border.width: 1
                    border.color: loginArea.lit ? root.ink : root.ruleStrong

                    Text {
                        anchors.centerIn: parent
                        text: "LOG IN"
                        color: root.ink
                        font.family: root.labelFont
                        font.pixelSize: 12.5 * root.unit
                        font.letterSpacing: 1.5 * root.unit
                    }

                    HitArea {
                        id: loginArea
                        anchors.fill: parent
                        onTriggered: root.login()
                    }
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round(parent.height * 0.807)
            spacing: 28 * root.unit

            PowerButton {
                visible: root.showAllPowerButtons || sddm.canPowerOff
                label: "Shut down"
                icon: "M12 3v8M6.3 6.3a8 8 0 1 0 11.4 0"
                unit: root.unit
                ink: root.ink
                muted: root.muted
                labelFont: root.labelFont
                onClicked: sddm.powerOff()
            }

            PowerButton {
                visible: root.showAllPowerButtons || sddm.canReboot
                label: "Reboot"
                icon: "M20 12a8 8 0 1 1-2.34-5.66M20 4v4h-4"
                unit: root.unit
                ink: root.ink
                muted: root.muted
                labelFont: root.labelFont
                onClicked: sddm.reboot()
            }

            PowerButton {
                visible: root.showAllPowerButtons || sddm.canSuspend
                label: "Suspend"
                icon: "M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5z"
                unit: root.unit
                ink: root.ink
                muted: root.muted
                labelFont: root.labelFont
                onClicked: sddm.suspend()
            }

            PowerButton {
                visible: root.showAllPowerButtons || sddm.canHibernate
                label: "Hibernate"
                icon: "M2 12h20M12 2v20M20 16l-4-4 4-4M4 8l4 4-4 4M16 4l-4 4-4-4M8 20l4-4 4 4"
                unit: root.unit
                ink: root.ink
                muted: root.muted
                labelFont: root.labelFont
                onClicked: sddm.hibernate()
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round(parent.height * 0.93)
            spacing: 28 * root.unit

            Item {
                width: sessionLabel.width
                height: sessionLabel.height

                Text {
                    id: sessionLabel
                    text: ("Session · " + root.sessionName).toUpperCase()
                    color: sessionArea.lit ? root.ink : root.muted
                    font.family: root.labelFont
                    font.pixelSize: 12 * root.unit
                    font.letterSpacing: 0.96 * root.unit
                }

                Rectangle {
                    visible: sessions.count > 1
                    y: sessionLabel.baselineOffset + 5 * root.unit
                    width: parent.width
                    height: 1
                    color: sessionArea.lit ? root.ink : root.ruleStrong
                }

                HitArea {
                    id: sessionArea
                    anchors.fill: parent
                    anchors.margins: -12 * root.unit
                    enabled: sessions.count > 1
                    onTriggered: root.sessionIndex = (root.sessionIndex + 1) % sessions.count
                }
            }

            Text {
                visible: root.layoutName !== ""
                text: ("Keyboard · " + root.layoutName).toUpperCase()
                color: root.muted
                font.family: root.labelFont
                font.pixelSize: 12 * root.unit
                font.letterSpacing: 0.96 * root.unit
            }
        }
    }

    Row {
        x: 64 * root.unit
        height: 80 * root.unit
        spacing: 10 * root.unit

        Item {
            width: 14 * root.unit
            height: parent.height

            Mark {
                anchors.centerIn: parent
                scale: root.unit
                ink: root.ink
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: config.HostLabel === undefined ? sddm.hostName : config.HostLabel
            color: root.ink
            font.family: root.textFont
            font.weight: Font.Medium
            font.pixelSize: 20 * root.unit
        }
    }

    Text {
        id: osLabel
        x: 64 * root.unit
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30 * root.unit
        text: config.OsLabel || ""
        color: root.muted
        font.family: root.labelFont
        font.pixelSize: 12 * root.unit
        font.letterSpacing: 0.48 * root.unit
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 52 * root.unit
        anchors.verticalCenter: osLabel.verticalCenter
        spacing: 4 * root.unit

        Text {
            id: caption
            anchors.verticalCenter: parent.verticalCenter
            text: orrery.caption.toUpperCase()
            color: captionArea.lit ? root.ink : root.muted
            font.family: root.labelFont
            font.pixelSize: 12 * root.unit
            font.letterSpacing: 1.44 * root.unit

            Rectangle {
                visible: captionArea.activeFocus
                y: parent.baselineOffset + 5 * root.unit
                width: parent.width
                height: 1
                color: root.ink
            }

            HitArea {
                id: captionArea
                anchors.fill: parent
                anchors.margins: -12 * root.unit
                onTriggered: orrery.standOnNext()
            }
        }

        Item {
            width: 44 * root.unit
            height: 44 * root.unit

            readonly property color tone: playArea.lit ? root.ink : root.faint

            Row {
                visible: orrery.playing
                anchors.centerIn: parent
                spacing: 3.2 * root.unit

                Rectangle { width: 2.4 * root.unit; height: 9 * root.unit; radius: 0.6 * root.unit; color: parent.parent.tone }
                Rectangle { width: 2.4 * root.unit; height: 9 * root.unit; radius: 0.6 * root.unit; color: parent.parent.tone }
            }

            Canvas {
                id: playIcon
                visible: !orrery.playing
                anchors.centerIn: parent
                width: 12 * root.unit
                height: 12 * root.unit
                property color tone: parent.tone
                onToneChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.scale(width / 14, height / 14);
                    ctx.fillStyle = tone;
                    ctx.beginPath();
                    ctx.moveTo(4, 2.5);
                    ctx.lineTo(4, 11.5);
                    ctx.lineTo(11.5, 7);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            Rectangle {
                visible: playArea.activeFocus
                x: (parent.width - width) / 2
                y: caption.y - parent.y + caption.baselineOffset + 5 * root.unit
                width: 12 * root.unit
                height: 1
                color: root.ink
            }

            HitArea {
                id: playArea
                anchors.fill: parent
                enabled: !orrery.intro
                onTriggered: orrery.playing = !orrery.playing
            }
        }
    }

    SequentialAnimation {
        id: shake
        NumberAnimation { target: nudge; property: "x"; to: -6 * root.unit; duration: 76; easing.type: Easing.InOutQuad }
        NumberAnimation { target: nudge; property: "x"; to: 5 * root.unit; duration: 76; easing.type: Easing.InOutQuad }
        NumberAnimation { target: nudge; property: "x"; to: -3 * root.unit; duration: 76; easing.type: Easing.InOutQuad }
        NumberAnimation { target: nudge; property: "x"; to: 2 * root.unit; duration: 76; easing.type: Easing.InOutQuad }
        NumberAnimation { target: nudge; property: "x"; to: 0; duration: 76; easing.type: Easing.InOutQuad }
    }
}
