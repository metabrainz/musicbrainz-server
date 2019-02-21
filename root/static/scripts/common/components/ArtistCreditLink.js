/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EntityLink from './EntityLink';

const ArtistCreditLink = ({artistCredit, showDeleted = true, ...props}) => {
  const parts = [];
  for (let i = 0; i < artistCredit.length; i++) {
    const credit = artistCredit[i];
    if (props.plain) {
      parts.push(credit.name);
    } else {
      let artist = credit.artist;
      if (!artist) {
        artist = {entityType: 'artist', name: credit.name};
      }
      parts.push(
        <EntityLink
          content={credit.name}
          entity={artist}
          key={i}
          showDeleted={showDeleted}
          target={props.target}
        />,
      );
    }
    parts.push(credit.joinPhrase);
  }
  return parts;
};

export default ArtistCreditLink;
