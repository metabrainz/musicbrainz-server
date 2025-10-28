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
import useReleaseLanguageColumn from './hooks/useReleaseLanguageColumn.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

component NoScript(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  const releaseLanguageColumn = useReleaseLanguageColumn<ReportReleaseT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows releases that have no script set. If you
        recognize the script, just add it! Remember that the script used
        for English (and most other European languages) is Latin.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports('Releases without script')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsAfter={releaseLanguageColumn}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default NoScript;
