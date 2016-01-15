const parseInteger = require('./parseInteger');

module.exports = function (str) {
    var integer = parseInteger(str);
    return isNaN(integer) ? null : integer;
};
