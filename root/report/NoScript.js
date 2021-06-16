/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList';
import ReportLayout from './components/ReportLayout';
import useReleaseLanguageColumn from './hooks/useReleaseLanguageColumn';
import type {ReportDataT, ReportReleaseT} from './types';

const NoScript = ({
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
        `This report shows releases that have no script set. If you
        recognize the script, just add it! Remember that the script used
        for English (and most other European languages) is Latin.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases without script')}
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

export default NoScript;
