if (typeof global === 'undefined') {
  module.exports = window;
} else {
  module.exports = global;
}
