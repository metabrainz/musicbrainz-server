/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseUrlList from './components/ReleaseUrlList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseUrlT} from './types';

const AsinsWithMultipleReleases = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows Amazon URLs which are linked to multiple
       releases. In most cases Amazon ASINs should map to MusicBrainz
       releases 1:1, so only one of the links will be correct. Just check
       which MusicBrainz release fits the release in Amazon (look at the
       format, tracklist, etc). If the release has a barcode, you can also
       search Amazon for it and see which ASIN matches.  You might also
       find some ASINs linked to several discs of a multi-disc release:
       just merge those (see
       {how_to_merge_releases|How to Merge Releases}).`,
      {how_to_merge_releases: '/doc/How_to_Merge_Releases'},
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Amazon URLs linked to multiple releases')}
    totalEntries={pager.total_entries}
  >
    <ReleaseUrlList items={items} pager={pager} />
  </ReportLayout>
);

export default AsinsWithMultipleReleases;
