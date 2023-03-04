/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

function setlistLink(
  entityType: string,
  entityGid: string,
  content: string,
) {
  let formattedContent = content;
  if (empty(formattedContent)) {
    formattedContent = entityType + ':' + entityGid;
  }

  return (
    <a href={`/${entityType}/${entityGid}`}>
      {formattedContent}
    </a>
  );
}

const linkRegExp =
  /^\[([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(?:\|([^\]]+))?\]/i;

function formatSetlistArtist(content: string, entityGid?: string) {
  return (
    <strong>
      {addColonText(l('Artist'))}
      {' '}
      {nonEmpty(entityGid)
        ? setlistLink('artist', entityGid, content)
        : content}
    </strong>
  );
}

function formatSetlistWork(content: string, entityGid?: string) {
  return nonEmpty(entityGid)
    ? setlistLink('work', entityGid, content)
    : content;
}

export default function formatSetlist(
  setlistText: string,
): Expand2ReactOutput {
  const rawLines = setlistText.split(/(?:\r\n|\n\r|\r|\n)/);
  const elements: Array<React.Node> = [];

  for (const rawLine of rawLines) {
    if (empty(rawLine)) {
      elements.push(<br />);
      continue;
    }

    const symbol = rawLine.substring(0, 2);
    const line = rawLine.substring(2);
    let entityType;

    switch (symbol) {
      // Lines starting with @ are artists
      case '@ ':
        entityType = 'artist';
        break;

      // Lines starting with * are works
      case '* ':
        entityType = 'work';
        break;

      // Lines starting with # are comments
      case '# ':
        elements.push(<span className="comment">{line}</span>);
        break;

      // Lines that don't start with a symbol are ignored
    }

    if (entityType) {
      const startingBracketRegExp = /\[/g;

      let match;
      let lastIndex = 0;
      let didMatchStartingBracket = false;

      while ((match = startingBracketRegExp.exec(line))) {
        didMatchStartingBracket = true;
        const textBeforeMatch = line.substring(lastIndex, match.index);
        elements.push(textBeforeMatch);
        lastIndex = match.index;

        const remainder = line.substring(match.index);
        const linkMatch = remainder.match(linkRegExp);

        if (linkMatch) {
          const [linkMatchText, entityGid, content] = linkMatch;
          switch (entityType) {
            case 'artist':
              elements.push(formatSetlistArtist(content, entityGid));
              break;
            case 'work':
              elements.push(formatSetlistWork(content, entityGid));
              break;
          }
          lastIndex += linkMatchText.length;
        }
      }

      if (didMatchStartingBracket) {
        elements.push(line.substring(lastIndex));
      } else {
        switch (entityType) {
          case 'artist':
            elements.push(formatSetlistArtist(line));
            break;
          case 'work':
            elements.push(formatSetlistWork(line));
            break;
        }
      }
    }

    elements.push(<br />);
  }

  return React.createElement(React.Fragment, null, ...elements);
}
