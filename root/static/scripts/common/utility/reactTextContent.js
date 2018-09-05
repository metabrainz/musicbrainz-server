/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import nonEmpty from './nonEmpty';

function reactTextContent(reactElement, previous = '') {
  if (!React.isValidElement(reactElement)) {
    return previous + String(reactElement);
  }

  const props = reactElement.props;

  if (!nonEmpty(props)) {
    return previous;
  }

  let children = props.children;

  if (nonEmpty(children)) {
    if (Array.isArray(children)) {
      for (let i = 0; i < children.length; i++) {
        previous = reactTextContent(children[i], previous);
      }
      return previous;
    }
    if (React.isValidElement(children)) {
      return reactTextContent(children, previous);
    }
    return previous + children;
  }

  return previous;
}

export default reactTextContent;
