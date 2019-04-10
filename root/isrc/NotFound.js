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

const ISRCNotFound = () => (
  <NotFound title={l('ISRC Not Currently Used')}>
    <p>
      {exp.l('This ISRC is not associated with any recordings. If you wish to associate it with a recording, please {search_url|search for the recording} and add it.',
        {search_url: '/search'})}
    </p>
  </NotFound>
);

export default ISRCNotFound;
