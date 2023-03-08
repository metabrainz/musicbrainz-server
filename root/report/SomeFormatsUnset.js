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

const SomeFormatsUnset = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases where some of the medium formats are
       set, but others are unset. In most cases, it should be easy to
       find out which the correct formats are (don't just assume that
       they're all CDs because one is though!).`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with some formats unset')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default SomeFormatsUnset;
