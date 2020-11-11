/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from './components/ArtistList';
import ReportLayout from './components/ReportLayout';
import type {ReportArtistT, ReportDataT} from './types';

const ArtistsDisambiguationSameName = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists artists that have their disambiguation set
       to be the same as their name.
       The disambiguation should be removed or, if it is needed, improved.`,
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Artists with disambiguation the same as the name')}
    totalEntries={pager.total_entries}
  >
    <ArtistList items={items} pager={pager} />
  </ReportLayout>
);

export default ArtistsDisambiguationSameName;
