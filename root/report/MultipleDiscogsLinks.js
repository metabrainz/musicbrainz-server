/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const MultipleDiscogsLinks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows releases that have more than one link to Discogs.
       In most cases a MusicBrainz release should have only one equivalent
       in Discogs, so only one of them will be correct. Just check which
       ones do not fit the release (because of format, different number of
       tracks, etc). Any "master" Discogs page belongs at the
       {release_group|release group level}, not at the release level, and
       should be removed from releases too.`,
      {release_group: '/doc/Release_Group'},
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with multiple Discogs links')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default MultipleDiscogsLinks;
