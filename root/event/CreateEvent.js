/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import * as manifest from '../static/manifest.mjs';
import EventEditForm
  from '../static/scripts/event/components/EventEditForm.js';

import type {EventFormT} from './types.js';

type Props = {
  +eventDescriptions: {+[id: string]: string},
  +eventTypes: SelectOptionsT,
  +form: EventFormT,
};

const CreateEvent = ({
  eventDescriptions,
  eventTypes,
  form,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={lp('Add event', 'header')}>
    <div id="content">
      <h1>{lp('Add event', 'header')}</h1>
      <EventEditForm
        eventDescriptions={eventDescriptions}
        eventTypes={eventTypes}
        form={form}
      />
    </div>
    {manifest.js('event/components/EventEditForm', {async: 'async'})}
    {manifest.js('relationship-editor', {async: 'async'})}
  </Layout>
);

export default CreateEvent;
