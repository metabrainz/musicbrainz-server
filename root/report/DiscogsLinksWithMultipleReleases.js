/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseUrlList from './components/ReleaseUrlList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseUrlT} from './types.js';

const DiscogsLinksWithMultipleReleases = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows Discogs URLs which are linked to multiple
       releases. In most cases Discogs releases should map to MusicBrainz
       releases 1:1, so only one of the links will be correct. Just check
       which MusicBrainz release fits the release in Discogs (look at the
       format, tracklist, release country, etc.). You might also find some
       Discogs URLs linked to several discs of a multi-disc release: just
       merge those (see {how_to_merge_releases|How to Merge Releases}).`,
      {how_to_merge_releases: '/doc/How_to_Merge_Releases'},
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Discogs URLs linked to multiple releases')}
    totalEntries={pager.total_entries}
  >
    <ReleaseUrlList items={items} pager={pager} />
  </ReportLayout>
);

export default DiscogsLinksWithMultipleReleases;
