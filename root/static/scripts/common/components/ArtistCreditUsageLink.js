/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {reduceArtistCredit} from '../immutable-entities';

type Props = {
  +artistCredit: ArtistCreditT,
  +content?: string,
  +subPath?: string,
  +target?: '_blank',
};

const ArtistCreditUsageLink = ({
  artistCredit,
  content,
  subPath,
  ...props
}: Props): React.Element<'a'> | null => {
  const id = artistCredit.id;
  if (id == null) {
    return null;
  }
  let href = `/artist-credit/${id}`;
  if (nonEmpty(subPath)) {
    href += '/' + subPath;
  }
  return (
    <a href={href} {...props}>
      {nonEmpty(content) ? content : reduceArtistCredit(artistCredit)}
    </a>
  );
};

export default ArtistCreditUsageLink;
