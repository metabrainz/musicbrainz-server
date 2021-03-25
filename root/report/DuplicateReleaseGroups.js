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

const DuplicateReleaseGroups = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report lists release groups with very similar names and
       artists. If the releases in the release groups should be grouped
       together (see the {url|guidelines}), they can be merged. If they
       shouldn\'t be grouped together but they can be distinguished by
       the release group types, e.g. when an artist has an album and
       single with the same name, then there is usually no need to
       change anything. In other cases, a disambiguation comment may be
       helpful.`,
      {url: '/doc/Style/Release_Group'},
    )}
    entityType="release_group"
    filtered={filtered}
    generated={generated}
    title={l('Possible duplicate release groups')}
    totalEntries={pager.total_entries}
  >
    <ReleaseGroupList items={items} pager={pager} />
  </ReportLayout>
);

export default DuplicateReleaseGroups;
