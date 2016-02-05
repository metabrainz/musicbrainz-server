// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const nonEmpty = require('./nonEmpty');

function reactTextContent(reactElement, previous = '') {
  if (!nonEmpty(reactElement.props)) {
    return previous;
  }

  let children = reactElement.props.children;

  if (nonEmpty(children)) {
    if (Array.isArray(children)) {
      return children.reduce(reactTextContent, previous);
    }
    return previous + children;
  }

  return previous;
}

module.exports = reactTextContent;
