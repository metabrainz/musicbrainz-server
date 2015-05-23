var cookie = require('cookie');

module.exports = function (name, string) {
    return cookie.parse(string || document.cookie)[name];
};
