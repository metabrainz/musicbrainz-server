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

type Props = {
  +entityType: 'release' | 'recording',
  +mbids: string | $ReadOnlyArray<string>,
};

function getListenBrainzLink(
  entityType: 'release' | 'recording',
  mbids: string | $ReadOnlyArray<string>,
): string | null {
  let formattedMbids;

  if (Array.isArray(mbids)) {
    formattedMbids = mbids.join(',');
  } else {
    formattedMbids = mbids;
  }

  if (entityType === 'release') {
    return `//listenbrainz.org/player/release/${formattedMbids}`;
  }

  if (entityType === 'recording') {
    return `//listenbrainz.org/player?recording_mbids=${formattedMbids}`;
  }

  return null;
}

const PlayOnListenBrainzButton = ({
  entityType,
  mbids,
}: Props): React$Element<'a'> | null => {
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
};

export default PlayOnListenBrainzButton;
