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

const ArtistsWithNoSubscribers = ({
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
      `This report lists artists that have no editors subscribed to them,
       and whose changes may therefore be under-reviewed. Artists with
       more release groups and more open edits are listed first.`,
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Artists with no subscribers')}
    totalEntries={pager.total_entries}
  >
    <ArtistList items={items} pager={pager} />
  </ReportLayout>
);

export default ArtistsWithNoSubscribers;
