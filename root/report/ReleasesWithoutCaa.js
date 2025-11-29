/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

component ReleasesWithoutCaa(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l_reports(
        `This report shows releases that have no cover art in the Cover Art
         Archive. Given that most releases have some form of cover art, the
         vast majority of releases in this report should have artwork 
         {caa_how_to|uploaded to the Cover Art Archive}.
         Note that the cover art uploaded for a release must always exactly
         match the actual art for that specific release (for example,
         they should have the same barcode, format, etc.).
         This report skips pseudo-releases, since they should generally
         not have cover art.`,
        {caa_how_to: '/doc/How_to_Add_Cover_Art'},
      )}
      entityType="release"
      extraInfo={l_reports(
        `We strongly suggest restricting this report to entities
         in your subscriptions only for a more manageable list of results.`,
      )}
      filtered={filtered}
      generated={generated}
      title={l_reports('Releases without any art in the Cover Art Archive')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default ReleasesWithoutCaa;
