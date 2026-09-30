/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReportLayout from './components/ReportLayout.js';
import WorkList from './components/WorkList.js';
import type {ReportDataT, ReportWorkT} from './types.js';

component RedundantWriterRelationships(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows works which have a writer relationship and a
         composer or lyricist relationship to the same artist.
         Writer is generally used as a more generic alternative when
         it is not known if an artist was a lyricist, composer, or both.
         As such, in most cases both of these relationships should not
         be present at the same time.`,
      )}
      entityType="work"
      filtered={filtered}
      generated={generated}
      title={l('Works with possibly redundant writer relationships')}
      totalEntries={pager.total_entries}
    >
      <WorkList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default RedundantWriterRelationships;
