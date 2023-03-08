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
import useCatNoColumn from './hooks/useCatNoColumn.js';
import type {ReportDataT, ReportReleaseCatNoT} from './types.js';

const CatNoLooksLikeAsin = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseCatNoT>): React$Element<typeof ReportLayout> => {
  const catNoColumn = useCatNoColumn<ReportReleaseCatNoT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows releases which have catalog numbers that look
         like ASINs. This is almost always wrong: ASINs are just Amazon's
         entries for the releases and should be linked to the release
         with an Amazon URL relationship instead.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases with catalog numbers that look like ASINs')}
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

export default CatNoLooksLikeAsin;
