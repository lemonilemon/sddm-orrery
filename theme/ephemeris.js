.pragma library

const EPOCH = Date.UTC(2000, 0, 1, 12);
const YEAR = 365.25 * 86400000;

// J2000 mean elements: semi-major axis (AU), mean longitude (deg), its rate
// (deg per Julian year), longitude of perihelion (deg), eccentricity.
const ELEMENTS = {
    venus: [0.72333, 181.97973, 585.17815, 131.53298, 0.00677],
    earth: [1.0, 100.46435, 359.99372, 102.94719, 0.01671],
    mars: [1.52368, 355.45332, 191.40303, 336.04084, 0.0934]
};

function yearsSinceJ2000(date) {
    return (date.getTime() - EPOCH) / YEAR;
}

function dateAt(t) {
    return new Date(EPOCH + t * YEAR);
}

// Heliocentric ecliptic position in AU, y pointing down the screen.
function heliocentric(body, t) {
    const el = ELEMENTS[body];
    if (!el)
        return [0, 0];
    const deg = Math.PI / 180;
    const meanLongitude = (el[1] + el[2] * t) * deg;
    const meanAnomaly = meanLongitude - el[3] * deg;
    const longitude = meanLongitude + 2 * el[4] * Math.sin(meanAnomaly);
    const r = el[0] * (1 - el[4] * Math.cos(meanAnomaly));
    return [r * Math.cos(longitude), -r * Math.sin(longitude)];
}
