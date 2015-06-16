var cookie = require('cookie');

module.exports = function (name) {
    return cookie.parse(document.cookie)[name];
};
