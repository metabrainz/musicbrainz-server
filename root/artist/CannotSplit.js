/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistLayout from './ArtistLayout';

type Props = {
  +artist: ArtistT,
};

const CannotSplit = ({
  artist,
}: Props): React.Element<typeof ArtistLayout> => (
  <ArtistLayout entity={artist} page="cannot_split">
    <h2>{l('Split Into Separate Artists')}</h2>
    <p>
      {exp.l(
        `This artist has relationships other than collaboration
         relationships, and cannot be split until these are
         removed. {relationships|View all relationships}.`,
        {relationships: `/artist/${artist.gid}/relationships`},
      )}
    </p>
  </ArtistLayout>
);

export default CannotSplit;
