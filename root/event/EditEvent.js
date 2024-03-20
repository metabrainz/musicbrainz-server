/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as manifest from '../static/manifest.mjs';
import EventEditForm
  from '../static/scripts/event/components/EventEditForm.js';

import EventLayout from './EventLayout.js';
import type {EventFormT} from './types.js';

type Props = {
  +entity: EventT,
  +eventDescriptions: {+[id: string]: string},
  +eventTypes: SelectOptionsT,
  +form: EventFormT,
};

const EditEvent = ({
  entity,
  eventDescriptions,
  eventTypes,
  form,
}: Props): React$Element<typeof EventLayout> => (
  <EventLayout
    entity={entity}
    fullWidth
    page="edit"
    title={l('Edit event')}
  >
    <EventEditForm
      eventDescriptions={eventDescriptions}
      eventTypes={eventTypes}
      form={form}
    />
    {manifest.js('event/components/EventEditForm', {async: 'async'})}
    {manifest.js('relationship-editor', {async: 'async'})}
  </EventLayout>
);

export default EditEvent;
