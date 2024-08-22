/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

component BootlegsOnNonBootlegLabels(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows releases that are set to status “Bootleg”, but have
         at least one label in their labels list which is not “[no label]” nor
         has the type “Bootleg Production”.
         Other types of labels pretty much never release bootleg releases,
         so chances are that either the label or the status is wrong.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports('Releases on non-bootleg labels set to bootleg')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default BootlegsOnNonBootlegLabels;
