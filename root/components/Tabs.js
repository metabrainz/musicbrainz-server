/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type Props = {
  +children: React.Node,
};

const Tabs = ({children}: Props): React$Element<'div'> => (
  <div className="tabs">
    <ul className="tabs">
      {children}
    </ul>
  </div>
);

export default Tabs;
