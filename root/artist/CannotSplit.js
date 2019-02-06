/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../static/scripts/common/i18n';

import ArtistLayout from './ArtistLayout';

const CannotSplit = ({artist}: {artist: ArtistT}) => (
  <ArtistLayout entity={artist} page="cannot_split">
    <h2>{l('Split Into Separate Artists')}</h2>
    <p>
      {l(`This artist has relationships other than collaboration
          relationships, and cannot be split until these are
          removed. {relationships|View all relationships}.`,
      {relationships: `/artist/${artist.gid}/relationships`})}
    </p>
  </ArtistLayout>
);

export default CannotSplit;
