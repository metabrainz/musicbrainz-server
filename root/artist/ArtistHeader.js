/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityHeader from '../components/EntityHeader';

type Props = {
  +artist: ArtistT,
  +page: string,
};

const ArtistHeader = ({artist, page}: Props) => {
  let headerClass = 'artistheader';
  if (artist.typeName) {
    headerClass += ` ${artist.typeName.toLowerCase()}-icon`;
  }
  return (
    <EntityHeader
      entity={artist}
      headerClass={headerClass}
      page={page}
      subHeading={artist.typeName
        ? lp_attributes(artist.typeName, 'artist_type')
        : l('Artist')}
    />
  );
};

export default ArtistHeader;
