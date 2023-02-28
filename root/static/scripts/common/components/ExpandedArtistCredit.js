/*
 * @flow strict
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2019 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import commaOnlyList from '../i18n/commaOnlyList.js';

import ArtistCreditLink from './ArtistCreditLink.js';
import DescriptiveLink from './DescriptiveLink.js';

type Props = {
  +artistCredit: ArtistCreditT,
};

export const ExpandedArtistCreditList = ({
  artistCredit,
}: Props): React.Element<'span'> | null => {
  if (!artistCredit) {
    return null;
  }

  const names = artistCredit.names;
  let artistList: Array<Expand2ReactOutput> = [];

  if (names.some(x => x.artist.name !== x.name || x.artist.comment)) {
    artistList = names.map(name => {
      if (name.artist.name === name.name) {
        return <DescriptiveLink entity={name.artist} />;
      }
      return exp.l(
        '{artist} as {name}',
        {
          artist: <DescriptiveLink entity={name.artist} />,
          name: name.name,
        },
      );
    });
  }

  if (artistList.length) {
    return (
      <span className="expanded-ac-list">{commaOnlyList(artistList)}</span>
    );
  }

  return null;
};

const ExpandedArtistCredit = ({artistCredit}: Props): React.MixedElement => (
  <>
    <ArtistCreditLink artistCredit={artistCredit} />
    <br />
    <ExpandedArtistCreditList artistCredit={artistCredit} />
  </>
);

export default ExpandedArtistCredit;
