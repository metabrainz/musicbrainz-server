/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistRelationshipList from './components/ArtistRelationshipList';
import ReportLayout from './components/ReportLayout';
import type {ReportArtistRelationshipT, ReportDataT} from './types';

const DeprecatedRelationshipArtists = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists artists which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Artists with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <ArtistRelationshipList items={items} pager={pager} />
  </ReportLayout>
);

export default DeprecatedRelationshipArtists;
