// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015–2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const EntityLink = require('./EntityLink');

const ArtistCreditLink = ({artistCredit, showDeleted = true, ...props}) => {
  const names = artistCredit.names;
  let parts = [];
  for (let i = 0; i < names.size; i++) {
    let credit = names.get(i);
    if (props.plain) {
      parts.push(credit.name);
    } else {
      parts.push(
        <EntityLink
          content={credit.name}
          entity={credit.artist}
          key={i}
          showDeleted={showDeleted} />
        );
    }
    parts.push(credit.joinPhrase);
  }
  return <frag>{parts}</frag>;
};

module.exports = ArtistCreditLink;
