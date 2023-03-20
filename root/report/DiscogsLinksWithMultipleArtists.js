/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistUrlList from './components/ArtistUrlList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistUrlT, ReportDataT} from './types.js';

const DiscogsLinksWithMultipleArtists = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistUrlT>):
React$Element<typeof ReportLayout> => (
  <ReportLayout
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
