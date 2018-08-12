/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import NotFound from '../components/NotFound';
import {l} from '../static/scripts/common/i18n';

const EventNotFound = () => (
  <NotFound title={l('Event Not Found')}>
    <p>
      {l('Sorry, we could not find an event with that MusicBrainz ID. You may wish to try and {search_url|search for it} instead.',
        {__react: true, search_url: '/search'})}
    </p>
  </NotFound>
);

export default EventNotFound;
