/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import LastUpdated from './LastUpdated';

const GenreSidebar = ({genre}: {genre: GenreT}) => {
  return (
    <div id="sidebar">
      <LastUpdated entity={genre} />
    </div>
  );
};

export default GenreSidebar;
