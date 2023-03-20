/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {reduceArtistCredit} from '../immutable-entities.js';

import {MpIcon} from './ArtistCreditLink.js';

type Props = {
  +artistCredit: ArtistCreditT,
  +content?: string,
  +showEditsPending?: boolean,
  +subPath?: string,
  +target?: '_blank',
};

const ArtistCreditUsageLink = ({
  artistCredit,
  content,
  showEditsPending = false,
  subPath,
  ...props
}: Props): React$Element<'a' | 'span'> | null => {
  const id = artistCredit.id;
  if (id == null) {
    return null;
  }
  let href = `/artist-credit/${id}`;
  if (nonEmpty(subPath)) {
    href += '/' + subPath;
  }

  const artistCreditLink = (
    <a href={href} {...props}>
      {nonEmpty(content) ? content : reduceArtistCredit(artistCredit)}
    </a>
  );

  return (
    artistCredit.editsPending /*:: === true */ && showEditsPending ? (
      <span className="mp">
        {artistCreditLink}
        <MpIcon artistCredit={artistCredit} />
      </span>
    ) : artistCreditLink
  );
};

export default ArtistCreditUsageLink;
