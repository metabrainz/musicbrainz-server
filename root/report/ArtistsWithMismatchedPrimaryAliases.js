/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistList from './components/ArtistList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistT, ReportDataT} from './types.js';

component ArtistsWithMismatchedPrimaryAliases(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report lists artists that have at least one alias marked as
         primary for a locale, but have no primary aliases that match their
         name. In general, the main name for an artist should always be
         its primary alias in the language of the name.`,
      )}
      entityType="artist"
      filtered={filtered}
      generated={generated}
      title={l('Artists with mismatched primary aliases')}
      totalEntries={pager.total_entries}
    >
      <ArtistList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default ArtistsWithMismatchedPrimaryAliases;
