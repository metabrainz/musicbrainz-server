/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipsTable from '../components/RelationshipsTable.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';


import ArtistLayout from './ArtistLayout.js';

type Props = {
  +$c: CatalystContextT,
  +artist: ArtistT,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
};

const ArtistRelationships = ({
  $c,
  artist,
  pagedLinkTypeGroup,
  pager,
}: Props): React.Element<typeof ArtistLayout> => (
  <ArtistLayout
    entity={artist}
    page="relationships"
    title={l('Relationships')}
  >
    {pagedLinkTypeGroup ? null : (
      <Relationships showIfEmpty source={artist} />
    )}
    <RelationshipsTable
      $c={$c}
      entity={artist}
      heading={l('Appearances')}
      pagedLinkTypeGroup={pagedLinkTypeGroup}
      pager={pager}
    />
  </ArtistLayout>
);

export default ArtistRelationships;
