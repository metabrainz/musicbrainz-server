/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from '../i18n/expand2react';

function setlistLink(entityType, entityGid, content) {
  let formattedContent = content;
  if (!nonEmpty(formattedContent)) {
    formattedContent = entityType + ':' + entityGid;
  }

  return `<a href="/${entityType}/${entityGid}">${formattedContent}</a>`;
}

function replaceSetlistMbids(entityType, setlistLine) {
  const formattedLine = setlistLine.replace(
    /\[([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(?:\|([^\]]+))?\]/ig,
    function (match, p1, p2) {
      return setlistLink(entityType, p1, p2);
    },
  );

  return formattedLine;
}

function formatSetlistArtist(setlistLine) {
  const artistLineLabel = addColonText(l('Artist'));
  const artistLineContent = replaceSetlistMbids('artist', setlistLine);

  const artistLine =
    `<strong>${artistLineLabel} ${artistLineContent}</strong>`;

  return artistLine;
}

function formatSetlistWork(setlistLine) {
  return replaceSetlistMbids('work', setlistLine);
}

export default function formatSetlist(
  setlistText: string,
): Expand2ReactOutput {
  let formattedText = setlistText;

  // Encode < and >
  formattedText = formattedText.replace(/</g, '&lt;');
  formattedText = formattedText.replace(/>/g, '&gt;');

  // Lines starting with @ are artists
  formattedText = formattedText.replace(
    /^@ ([^\r\n]*)/gm,
    function (match, p1) {
      return formatSetlistArtist(p1);
    },
  );

  // Lines starting with * are works
  formattedText = formattedText.replace(
    /^\* ([^\r\n]*)/gm,
    function (match, p1) {
      return formatSetlistWork(p1);
    },
  );

  // Lines starting with # are comments
  formattedText = formattedText.replace(
    /^# ([^\r\n]*)/gm,
    function (match, p1) {
      return '<span class=\"comment\">' + p1 + '<\/span>';
    },
  );

  // Fix newlines
  formattedText = formattedText.replace(/(\015\012|\012\015|\012|\015)/g, '<br \/>');

  return expand2react(formattedText);
}
