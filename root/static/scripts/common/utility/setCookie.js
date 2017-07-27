const cookie = require('cookie');

const _cookies = require('./_cookies');

function oneYearFromNow() {
    return new Date(Date.now() + (1000 * 60 * 60 * 24 * 365));
}

module.exports = function (name, value) {
    if (typeof document === 'undefined') {
        _cookies[name] = value;
    } else {
        document.cookie = cookie.serialize(name, value, {path: '/', expires: oneYearFromNow()});
    }
};
