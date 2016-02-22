const React = require('react');

function isolateText(content) {
  if (content) {
    return <bdi>{content}</bdi>;
  }
  return '';
}

module.exports = isolateText;
