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

component ArtistsDisambiguationSameName(...{
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
        `This report lists artists that have their disambiguation set
         to be the same as their name.
         The disambiguation should be removed or, if it is needed, improved.`,
      )}
      entityType="artist"
      filtered={filtered}
      generated={generated}
      title={l_reports('Artists with disambiguation the same as the name')}
      totalEntries={pager.total_entries}
    >
      <ArtistList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default ArtistsDisambiguationSameName;
