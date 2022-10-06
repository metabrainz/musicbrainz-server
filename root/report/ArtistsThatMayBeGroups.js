/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from './components/ArtistList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistT, ReportDataT} from './types.js';

const ArtistsThatMayBeGroups = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists artists that have their type set to other
       than Group (or a subtype of Group) but may be a group,
       because they have other artists listed as members. If you find
       that an artist here is indeed a group, change its type. If it is
       not, please make sure that the “member of” relationships are
       in the right direction and are correct.`,
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Artists that may be groups')}
    totalEntries={pager.total_entries}
  >
    <ArtistList items={items} pager={pager} />
  </ReportLayout>
);

export default ArtistsThatMayBeGroups;
