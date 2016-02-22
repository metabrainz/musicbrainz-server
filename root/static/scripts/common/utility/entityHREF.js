const {ENTITIES} = require('../constants');
const nonEmpty = require('./nonEmpty');

const leadingSlash = /^\/?(.*)/;

function entityHREF(entityType, id, subPath) {
  let href = '/' + ENTITIES[entityType].url + '/' + encodeURIComponent(id);

  if (nonEmpty(subPath)) {
    subPath = subPath.replace(leadingSlash, '$1');
    if (subPath) {
      href += '/' + subPath;
    }
  }

  return href;
}

module.exports = entityHREF;
