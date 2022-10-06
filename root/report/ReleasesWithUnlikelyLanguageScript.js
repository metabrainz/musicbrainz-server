/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import useReleaseLanguageColumn from './hooks/useReleaseLanguageColumn.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const ReleasesWithUnlikelyLanguageScript = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => {
  const releaseLanguageColumn = useReleaseLanguageColumn<ReportReleaseT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows releases that have an unlikely combination of
        language and script properties, such as German and Ethiopic.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases with unlikely language/script pairs')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsAfter={releaseLanguageColumn}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default ReleasesWithUnlikelyLanguageScript;
