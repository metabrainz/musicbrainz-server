/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const MislinkedPseudoReleases = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases with status Pseudo-Release that are
       marked as the original version of a translation/transliteration
       relationship. The pseudo-release should be the one marked as a
       translated/transliterated version instead. If both releases
       are pseudo-releases, consider linking both to an official release
       rather than to each other.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Translated/transliterated pseudo-releases marked as original')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default MislinkedPseudoReleases;
