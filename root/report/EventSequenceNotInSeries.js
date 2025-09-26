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

component EventSequenceNotInSeries(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists events where the event name indicates that it
         may have to be part of a series or a larger event.`,
      )}
      entityType="event"
      filtered={filtered}
      generated={generated}
      title={l_reports(
        'Events which should be part of series or larger event',
      )}
      totalEntries={pager.total_entries}
    >
      <EventList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default EventSequenceNotInSeries;
