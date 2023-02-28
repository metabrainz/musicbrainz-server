/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import NotFound from '../components/NotFound.js';

const TagLookupNotFound = (): React.Element<typeof NotFound> => (
  <NotFound title={l('Tag Lookup Error')}>
    <p>
      {l(
        `That search can't be performed, because you must provide at least one
         of 'recording', 'track number', 'duration', 'release', or 'artist'.`,
      )}
    </p>
    <p>
      {exp.l(
        `Please {search|try again}, providing at least 
         one of these parameters`,
        {search: '/taglookup'},
      )}
    </p>
  </NotFound>
);

export default TagLookupNotFound;
