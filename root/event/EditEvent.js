/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import EventEditForm
  from '../static/scripts/event/components/EventEditForm.js';

import EventLayout from './EventLayout.js';
import type {EventFormT} from './types.js';

component EditEvent(
  entity: EventT,
  eventDescriptions: {+[id: string]: string},
  eventTypes: SelectOptionsT,
  form: EventFormT,
) {
  return (
    <EventLayout
      entity={entity}
      fullWidth
      page="edit"
      title={lp('Edit event', 'header')}
    >
      <EventEditForm
        eventDescriptions={eventDescriptions}
        eventTypes={eventTypes}
        form={form}
      />
      {manifest('event/components/EventEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </EventLayout>
  );
}

export default EditEvent;
