/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EventList from './components/EventList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportEventT} from './types.js';

component EventsWithEaaNoTypes(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows events which have images in the Event Art
         Archive, but where none of the images have any types set.
         This often means a poster, flyer or banner was added, but not
         marked as such.`,
      )}
      entityType="event"
      filtered={filtered}
      generated={generated}
      title={l(`Events in the Event Art Archive
                where no event art piece has types`)}
      totalEntries={pager.total_entries}
    >
      <EventList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default EventsWithEaaNoTypes;
