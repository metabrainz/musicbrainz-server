/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {incrementCounter} from './numbers.js';

type SetlistEntityTypeT = 'artist' | 'work';

const linkRegExp =
  /^\[([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(?:\|([^\]]+))?\]/i;

/*
 * Decode only the HTML entities for the symbols [ and ] that can be escaped
 * from the setlist syntax, and for the symbol & from the HTML entity syntax.
 * Even though only the shortest full-letter syntax is recommended,
 * all equivalent syntaxes are supported and documented for convenience.
 * https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
 */
function decodeSomeHTMLEntities(content: ?string) {
  if (content == null) {
    return '';
  }
  return content
    .replace(/&#91;|&#x5b;|&lsqb;|&lbrack;/gi, '[')
    .replace(/&#93;|&#x5d;|&rsqb;|&rbrack;/gi, ']')
    .replace(/&#38;|&#x26;|&amp;/gi, '&'); // Replace all & at last and in one go
}

export default function formatSetlist(
  setlistText: string,
): Expand2ReactOutput {
  const rawLines = setlistText.split(/(?:\r\n|\n\r|\r|\n)/);
  const elements: Array<React.MixedElement | string> = [];
  const keys = new Map<string, number>();

  function setlistLink(
    entityType: SetlistEntityTypeT,
    entityGid: string,
    content: string,
  ) {
    let formattedContent = content;
    if (empty(formattedContent)) {
      formattedContent = entityType + ':' + entityGid;
    }

    return (
      <a
        href={`/${entityType}/${entityGid}`}
        key={entityType + '-' + String(incrementCounter(keys, entityGid))}
      >
        {formattedContent}
      </a>
    );
  }

  function formatSetlistArtist(content: string, entityGid?: string) {
    return (
      <strong
        key={'artist-' +
             String(incrementCounter(keys, entityGid ?? content))}
      >
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

  for (const rawLine of rawLines) {
    if (empty(rawLine)) {
      elements.push(
        <br key={'br-' + String(incrementCounter(keys, 'br'))} />,
      );
      continue;
    }

    const symbol = rawLine.substring(0, 2);
    const line = rawLine.substring(2);
    let entityType: ?SetlistEntityTypeT;

    match (symbol) {
      // Lines starting with @ are artists
      '@ ' => {
        entityType = 'artist';
      }

      // Lines starting with * are works
      '* ' => {
        entityType = 'work';
      }

      // Lines starting with # are comments
      '# ' => {
        elements.push(
          <span
            className="comment"
            key={'comment-' + String(incrementCounter(keys, 'comment'))}
          >
            {decodeSomeHTMLEntities(line)}
          </span>,
        );
      }

      _ => {
        // Lines that don't start with an accepted symbol are ignored
      }
    }

    if (nonEmpty(entityType)) {
      const startingBracketRegExp = /\[/g;

      let match;
      let lastIndex = 0;
      let didMatchStartingBracket = false;

      while ((match = startingBracketRegExp.exec(line))) {
        didMatchStartingBracket = true;
        const textBeforeMatch = line.substring(lastIndex, match.index);
        elements.push(decodeSomeHTMLEntities(textBeforeMatch));
        lastIndex = match.index;

        const remainder = line.substring(match.index);
        const linkMatch = remainder.match(linkRegExp);

        if (linkMatch) {
          const [linkMatchText, entityGid, content] = linkMatch;
          match (entityType) {
            'artist' => {
              elements.push(formatSetlistArtist(
                decodeSomeHTMLEntities(content),
                entityGid,
              ));
            }
            'work' => {
              elements.push(formatSetlistWork(
                decodeSomeHTMLEntities(content),
                entityGid,
              ));
            }
          }
          lastIndex += linkMatchText.length;
        }
      }

      if (didMatchStartingBracket) {
        elements.push(decodeSomeHTMLEntities(line.substring(lastIndex)));
      } else {
        match (entityType) {
          'artist' => {
            elements.push(formatSetlistArtist(decodeSomeHTMLEntities(line)));
          }
          'work' => {
            elements.push(formatSetlistWork(decodeSomeHTMLEntities(line)));
          }
        }
      }
    }

    elements.push(
      <br key={'br-' + String(incrementCounter(keys, 'br'))} />,
    );
  }

  return elements;
}
