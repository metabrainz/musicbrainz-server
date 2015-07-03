module.exports = function isBlank(str){
  return /^\s*$/.test(str || '');
};
