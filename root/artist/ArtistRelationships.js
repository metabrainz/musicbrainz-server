/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationships from '../components/Relationships';
import RelationshipsTable from '../components/RelationshipsTable';
import EntityLink from '../static/scripts/common/components/EntityLink';

import ArtistLayout from './ArtistLayout';

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
      artist.relationships?.length ? (
        <Relationships source={artist} />
      ) : (
        <>
          <h2 className="relationships">{l('Relationships')}</h2>
          <p>
            {exp.l(
              '{link} has no relationships.',
              {link: <EntityLink entity={artist} />},
            )}
          </p>
        </>
      )
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
