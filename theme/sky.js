.pragma library

function seeded(seed) {
    return function () {
        seed = (seed + 0x6d2b79f5) | 0;
        let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
        t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
}

// lemonilemon.csie.org's night sky: seed 7031 on a 1280x800 frame, scaled to
// cover the screen with its right edge pinned (SVG "xMaxYMid slice").
function stars(width, height) {
    const k = Math.max(width / 1280, height / 800);
    const ox = width - 1280 * k;
    const oy = (height - 800 * k) / 2;
    const rnd = seeded(7031);
    const dots = [];
    const sparks = [];
    for (let i = 0; i < 230; i++) {
        const x = Math.round(rnd() * 12800) / 10;
        const y = Math.round(rnd() * 8000) / 10;
        const mag = Math.pow(rnd(), 3);
        const phase = Math.floor(rnd() * 8);
        const star = { x: ox + x * k, y: oy + y * k, alpha: 0.18 + mag * 0.55, phase: phase };
        if (mag >= 0.86) {
            star.size = 10 * (0.6 + (mag - 0.86) * 2.5) * k;
            sparks.push(star);
        } else {
            star.size = 2 * (0.5 + mag * 1.3) * k;
            dots.push(star);
        }
    }
    return { dots: dots, sparks: sparks };
}
