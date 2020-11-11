/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseGroupList from './components/ReleaseGroupList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseGroupT} from './types';

const SetInDifferentRg = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows release groups with releases that are linked to
       releases in different release groups by part-of-set or
       transliteration relationships. If a pair of release groups are
       listed here, you should probably merge them. If the releases are
       discs linked with "part of set" relationships, you might want to
       merge them too into one multi-disc release
       (see {how_to_merge_releases|How to Merge Releases}).`,
      {how_to_merge_releases: '/doc/How_to_Merge_Releases'},
    )}
    entityType="release_group"
    filtered={filtered}
    generated={generated}
    title={l('Mismatched release groups')}
    totalEntries={pager.total_entries}
  >
    <ReleaseGroupList items={items} pager={pager} />
  </ReportLayout>
);

export default SetInDifferentRg;
