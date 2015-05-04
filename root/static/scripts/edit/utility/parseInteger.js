var regexp = /^[0-9]+$/;

module.exports = function (num) {
    return regexp.test(num) ? parseInt(num, 10) : NaN;
};
