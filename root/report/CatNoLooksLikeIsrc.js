/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
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

const CatNoLooksLikeIsrc = ({
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
         like {doc_link|ISRCs}. Assigning ISRCs to releases is almost
         always wrong, but still happens sometimes, especially for releases
         added to MusicBrainz by an artist/label. But ISRCs are codes assigned
         to recordings, and should be linked to the appropriate recording
         instead. That said, do make sure this is not a legitimate catalog
         number that just happens to look like an ISRC!`,
        {doc_link: '/doc/ISRC'},
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases with catalog numbers that look like ISRCs')}
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

export default CatNoLooksLikeIsrc;
