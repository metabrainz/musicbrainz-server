/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistUrlList from './components/ArtistUrlList';
import ReportLayout from './components/ReportLayout';
import type {ReportArtistUrlT, ReportDataT} from './types';

const DiscogsLinksWithMultipleArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistUrlT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows Discogs URLs which are linked to multiple artists.`,
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Discogs URLs linked to multiple artists')}
    totalEntries={pager.total_entries}
  >
    <ArtistUrlList items={items} pager={pager} />
  </ReportLayout>
);

export default DiscogsLinksWithMultipleArtists;
