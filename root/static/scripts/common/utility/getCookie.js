var cookie = require('cookie');

module.exports = function (name, string) {
    if (string || typeof document !== 'undefined') {
        return cookie.parse(string || document.cookie)[name];
    }
};
