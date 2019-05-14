/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import NotFound from '../components/NotFound';

const GenreNotFound = () => (
  <NotFound title={l('Genre Not Found')}>
    <p>
      {exp.l(
        `Sorry, we could not find a genre with that MusicBrainz ID. 
         You can see all available genres on our {genre_list|genre list}.`,
        {genre_list: '/genres'},
      )}
    </p>
  </NotFound>
);

export default GenreNotFound;
