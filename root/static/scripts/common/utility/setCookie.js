const cookie = require('cookie');

function oneYearFromNow() {
    return new Date(Date.now() + (1000 * 60 * 60 * 24 * 365));
}

module.exports = function (name, value) {
    document.cookie = cookie.serialize(name, value, {path: '/', expires: oneYearFromNow()});
};
