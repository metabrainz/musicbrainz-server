/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';

type Props = {
  +url: UrlT,
};

const UrlSidebar = ({url}: Props): React.Element<'div'> => {
  return (
    <div id="sidebar">
      <EditLinks entity={url} />

      <LastUpdated entity={url} />
    </div>
  );
};

export default UrlSidebar;
