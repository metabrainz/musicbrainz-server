module.exports = function clean(str) {
  return String(str || '').trim().replace(/\s+/g, ' ');
};
