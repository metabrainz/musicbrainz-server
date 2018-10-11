/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';

const UrlSidebar = ({url}: {url: UrlT}) => {
  return (
    <div id="sidebar">
      <EditLinks entity={url} />

      <LastUpdated entity={url} />
    </div>
  );
};

export default UrlSidebar;
