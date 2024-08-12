/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import EventEditForm
  from '../static/scripts/event/components/EventEditForm.js';

import type {EventFormT} from './types.js';

component CreateEvent(
  eventDescriptions: {+[id: string]: string},
  eventTypes: SelectOptionsT,
  form: EventFormT,
) {
  return (
    <Layout fullWidth title={lp('Add event', 'header')}>
      <div id="content">
        <h1>{lp('Add event', 'header')}</h1>
        <EventEditForm
          eventDescriptions={eventDescriptions}
          eventTypes={eventTypes}
          form={form}
        />
      </div>
      {manifest('event/components/EventEditForm', {async: 'async'})}
      {manifest('relationship-editor', {async: 'async'})}
    </Layout>
  );
}

export default CreateEvent;
