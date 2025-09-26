/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistList from './components/ArtistList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistT, ReportDataT} from './types.js';

component ArtistsWithMultipleOccurrencesInArtistCredits(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists artists that appear more than once
         in different positions within the same artist credit.`,
      )}
      entityType="artist"
      filtered={filtered}
      generated={generated}
      title={l_reports(
        'Artists occurring multiple times in the same artist credit',
      )}
      totalEntries={pager.total_entries}
    >
      <ArtistList items={items} pager={pager} subPath="aliases" />
    </ReportLayout>
  );
}

export default ArtistsWithMultipleOccurrencesInArtistCredits;
