/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseGroupList from './components/ReleaseGroupList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseGroupT} from './types.js';

component FeaturingReleaseGroups(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l_reports(
        `This report shows release groups with “(feat. Artist)” 
         (or similar) in the title. For classical release groups, 
         consult the {CSG|classical style guidelines}. For 
         non-classical release groups, this is usually inherited from an
         older version of MusicBrainz and should be fixed. Consult the
         {featured_artists|page about featured artists} to know more.`,
        {
          CSG: '/doc/Style/Classical',
          featured_artists: '/doc/Style/Artist_Credits#Featured_artists',
        },
      )}
      entityType="release_group"
      filtered={filtered}
      generated={generated}
      title={l_reports(
        'Release groups with titles containing featuring artists',
      )}
      totalEntries={pager.total_entries}
    >
      <ReleaseGroupList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default FeaturingReleaseGroups;
