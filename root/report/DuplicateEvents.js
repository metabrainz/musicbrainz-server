/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EventList from './components/EventList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportEventT} from './types.js';

const DuplicateEvents = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists events happening at the same place
       on the same date. If there are duplicates (for example,
       if there are separate events for headliner and supporting artist)
       please merge them.`,
    )}
    entityType="event"
    filtered={filtered}
    generated={generated}
    title={l('Possible duplicate events')}
    totalEntries={pager.total_entries}
  >
    <EventList items={items} pager={pager} />
  </ReportLayout>
);

export default DuplicateEvents;
