/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EntityLink, {DeletedLink} from './EntityLink';

type Props = {
  +artistCredit: ArtistCreditT,
  +plain?: boolean,
  +showDeleted?: boolean,
  +target?: '_blank',
};

const ArtistCreditLink = ({
  artistCredit,
  showDeleted = true,
  ...props
}: Props) => {
  const parts = [];
  for (let i = 0; i < artistCredit.length; i++) {
    const credit = artistCredit[i];
    if (props.plain) {
      parts.push(credit.name);
    } else {
      const artist = credit.artist;
      if (artist) {
        parts.push(
          <EntityLink
            content={credit.name}
            entity={artist}
            key={i}
            showDeleted={showDeleted}
            target={props.target}
          />,
        );
      } else {
        parts.push(
          <DeletedLink allowNew={false} name={credit.name} />,
        );
      }
    }
    parts.push(credit.joinPhrase);
  }
  return parts;
};

export default ArtistCreditLink;
