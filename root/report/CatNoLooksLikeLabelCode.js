/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import useCatNoColumn from './hooks/useCatNoColumn.js';
import type {ReportDataT, ReportReleaseCatNoT} from './types.js';


const CatNoLooksLikeLabelCode = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseCatNoT>): React.Element<typeof ReportLayout> => {
  const catNoColumn = useCatNoColumn<ReportReleaseCatNoT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l(
        `This report shows releases which have catalog numbers that look
         like {doc_link|Label Codes}. This is often wrong, since the two
         are often confused: label codes apply to the label, not to a
         specific release. If you confirm this is a label code (check
         the label page to see if they match, for example), remove it or,
         even better, try to find the actual catalog number.`,
        {doc_link: '/doc/Label/Label_Code'},
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases with catalog numbers that look like Label Codes')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsBefore={catNoColumn}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default CatNoLooksLikeLabelCode;
