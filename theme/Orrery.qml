import QtQuick
import "ephemeris.js" as Ephemeris

Item {
    id: orrery

    property color ink
    property real unit: 1
    property real centerX: width / 2
    property real centerY: height / 2
    property real auPixels: 210
    property string viewpoint: "earth"

    readonly property real today: Ephemeris.yearsSinceJ2000(new Date())
    property real t: intro ? today - 5 : today
    property real span: intro ? 0 : 5
    property bool intro: true
    property bool playing: false
    property string from: start
    property string to: start
    property real k: 1
    property var positions: ({})

    readonly property var bodies: ["sun", "venus", "earth", "mars"]
    readonly property string start: bodies.indexOf(viewpoint) >= 0 ? viewpoint : "earth"
    readonly property var sparkScale: ({ sun: 2.6, venus: 1.4, earth: 1.5, mars: 1.4 })
    readonly property var names: ({ sun: "the Sun", venus: "Venus", earth: "Earth", mars: "Mars" })
    readonly property string caption: "Seen from " + names[to] + " · "
        + Ephemeris.dateAt(t).toLocaleDateString(Qt.locale("en_US"), "d MMM yyyy")

    property double lastTick: 0

    function view(body, at) {
        const e = k * k * (3 - 2 * k);
        const f = Ephemeris.heliocentric(from, at);
        const g = Ephemeris.heliocentric(to, at);
        const q = Ephemeris.heliocentric(body, at);
        return [centerX + auPixels * (q[0] - (f[0] + (g[0] - f[0]) * e)),
                centerY + auPixels * (q[1] - (f[1] + (g[1] - f[1]) * e))];
    }

    function refresh() {
        const p = {};
        for (const body of bodies) {
            const v = view(body, t);
            p[body] = { x: v[0], y: v[1] };
        }
        positions = p;
        canvas.requestPaint();
    }

    function step() {
        const now = Date.now();
        const dt = lastTick ? Math.min(0.1, (now - lastTick) / 1000) : 0;
        lastTick = now;
        if (intro) {
            t = Math.min(today, t + 2 * dt);
            span = Math.min(5, span + 2 * dt);
            if (t >= today) {
                span = 5;
                intro = false;
            }
        } else if (playing) {
            t += 0.22 * dt;
        }
        if (k < 1)
            k = Math.min(1, k + dt / 1.6);
        refresh();
    }

    function standOn(body) {
        if (intro || k < 1 || body === to)
            return;
        from = to;
        to = body;
        k = 0;
    }

    function standOnNext() {
        standOn(bodies[(bodies.indexOf(to) + 1) % bodies.length]);
    }

    function rgba(alpha) {
        return "rgba(" + Math.round(ink.r * 255) + "," + Math.round(ink.g * 255) + ","
            + Math.round(ink.b * 255) + "," + alpha + ")";
    }

    onCenterXChanged: refresh()
    onCenterYChanged: refresh()
    onAuPixelsChanged: refresh()
    Component.onCompleted: refresh()

    Timer {
        interval: 33
        repeat: true
        running: orrery.intro || orrery.playing || orrery.k < 1
        onRunningChanged: orrery.lastTick = 0
        onTriggered: orrery.step()
    }

    Canvas {
        id: canvas

        readonly property real extent: 2.75 * orrery.auPixels

        x: orrery.centerX - extent
        y: orrery.centerY - extent
        width: 2 * extent
        height: 2 * extent

        function spark(ctx, x, y, size) {
            ctx.save();
            ctx.translate(x, y);
            ctx.scale(size, size);
            ctx.beginPath();
            ctx.moveTo(0, -5);
            ctx.bezierCurveTo(0.5, -1.3, 1.3, -0.5, 5, 0);
            ctx.bezierCurveTo(1.3, 0.5, 0.5, 1.3, 0, 5);
            ctx.bezierCurveTo(-0.5, 1.3, -1.3, 0.5, -5, 0);
            ctx.bezierCurveTo(-1.3, -0.5, -0.5, -1.3, 0, -5);
            ctx.closePath();
            ctx.fill();
            ctx.restore();
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const sun = orrery.positions.sun;
            if (!sun)
                return;
            ctx.translate(-x, -y);
            ctx.lineWidth = 1.1 * orrery.unit;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            const span = orrery.span;
            const n = Math.max(14, Math.round(span / 0.02));
            for (const body of orrery.bodies) {
                if (span <= 0 || (orrery.k >= 1 && body === orrery.to))
                    continue;
                const pts = [];
                for (let i = 0; i <= n; i++)
                    pts.push(orrery.view(body, orrery.t - span + i * span / n));
                for (let s = 0; s < 14; s++) {
                    const a = Math.floor(s * n / 14);
                    const b = Math.floor((s + 1) * n / 14);
                    const f = (s + 1) / 14;
                    ctx.strokeStyle = orrery.rgba(f * f * 0.6);
                    ctx.beginPath();
                    ctx.moveTo(pts[a][0], pts[a][1]);
                    for (let i = a + 1; i <= b; i++)
                        ctx.lineTo(pts[i][0], pts[i][1]);
                    ctx.stroke();
                }
            }
            ctx.fillStyle = orrery.rgba(0.06);
            ctx.beginPath();
            ctx.arc(sun.x, sun.y, 30 * orrery.unit, 0, 2 * Math.PI);
            ctx.fill();
            ctx.fillStyle = orrery.rgba(1);
            for (const body of orrery.bodies) {
                const p = orrery.positions[body];
                spark(ctx, p.x, p.y, orrery.sparkScale[body] * orrery.unit);
            }
        }
    }

    Repeater {
        model: orrery.bodies

        Item {
            id: stand

            required property string modelData
            readonly property var at: orrery.positions[modelData] || ({ x: -100, y: -100 })
            readonly property bool here: orrery.to === modelData

            x: at.x - width / 2
            y: at.y - height / 2
            width: 44 * orrery.unit
            height: width

            Rectangle {
                anchors.fill: parent
                anchors.margins: 8 * orrery.unit
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: orrery.ink
                opacity: area.containsMouse ? 0.6 : stand.here ? 0.28 : 0
                scale: area.containsMouse ? 1 : stand.here ? 1.25 : 0.6

                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: orrery.standOn(stand.modelData)
            }
        }
    }
}
