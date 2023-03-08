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

const SingleMediumReleasesWithMediumTitles = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases that have a single medium, where this
       medium also has a specific name. Usually, this is not necessary
       and is duplicate information which can be removed.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with a single medium that has a name')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default SingleMediumReleasesWithMediumTitles;
