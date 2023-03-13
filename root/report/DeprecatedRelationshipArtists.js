/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  relTypeColumn,
} from '../utility/tableColumns.js';

import ArtistList from './components/ArtistList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistRelationshipT, ReportDataT} from './types.js';

const DeprecatedRelationshipArtists = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistRelationshipT>):
React$Element<typeof ReportLayout> => (
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
    <ArtistList
      columnsBefore={[relTypeColumn]}
      items={items}
      pager={pager}
    />
  </ReportLayout>
);

export default DeprecatedRelationshipArtists;
