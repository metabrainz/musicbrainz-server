/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const ReleasesMissingDiscIds = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases (official and promotional only) that
       have at least one medium with a format that supports disc IDs,
       but is missing one.`,
    )}
    entityType="release"
    extraInfo={exp.l(
      `For instructions on how to add one, see the
       {add_discids|documentation page}.`,
      {add_discids: '/doc/How_to_Add_Disc_IDs'},
    )}
    filtered={filtered}
    generated={generated}
    title={l('Releases missing disc IDs')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default ReleasesMissingDiscIds;
