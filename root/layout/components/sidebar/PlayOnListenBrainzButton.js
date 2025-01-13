/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import listenBrainzIconUrl
  from '../../../static/images/icons/listenbrainz.png';

function getListenBrainzLink(
  entityType: 'album' | 'artist' | 'recording',
  mbids: string | $ReadOnlyArray<string>,
): string | null {
  let formattedMbids;

  if (Array.isArray(mbids)) {
    if (entityType === 'recording') {
      formattedMbids = encodeURIComponent(mbids.join(','));
    } else {
      // Multiple MBIDs are only supported for recordings
      return null;
    }
  } else {
    formattedMbids = encodeURIComponent(mbids);
  }

  if (entityType === 'artist') {
    return `//listenbrainz.org/artist/${formattedMbids}`;
  }

  if (entityType === 'album') {
    return `//listenbrainz.org/album/${formattedMbids}`;
  }

  if (entityType === 'recording') {
    return `//listenbrainz.org/player?recording_mbids=${formattedMbids}`;
  }

  return null;
}

component PlayOnListenBrainzButton(
  entityType: 'album' | 'artist' | 'recording',
  mbids: string | $ReadOnlyArray<string>,
) {
  const link = getListenBrainzLink(entityType, mbids);

  if (link == null) {
    return null;
  }

  return (
    <a
      className="styled-button listenbrainz-button"
      href={link}
      rel="noreferrer"
      target="_blank"
    >
      <img
        alt={l('ListenBrainz')}
        className="warning"
        src={listenBrainzIconUrl}
      />
      {' '}
      {l('Play on ListenBrainz')}
    </a>
  );
}

export default PlayOnListenBrainzButton;
