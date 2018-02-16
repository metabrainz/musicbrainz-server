/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const EntityLink = require('./EntityLink');

const ArtistCreditLink = ({artistCredit, showDeleted = true, ...props}) => {
  const names = artistCredit.names;
  const parts = [];
  for (let i = 0; i < names.size; i++) {
    const credit = names.get(i);
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

module.exports = ArtistCreditLink;
