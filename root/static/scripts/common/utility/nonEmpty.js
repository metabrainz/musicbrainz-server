function nonEmpty(value) {
  return value !== null && value !== undefined && value !== '';
}

module.exports = nonEmpty;
