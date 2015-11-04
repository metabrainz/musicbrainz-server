// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';
import Menu from './Menu';
import Search from './Search';

const Header = (props) => (
  <div id="header">
    <div id="header-logo">
      <a href="/" className="logo" title="MusicBrainz">
        <strong>MusicBrainz</strong>
      </a>
      <div>
        <Search {...props} />
      </div>
    </div>
    <Menu {...props} />
  </div>
);

export default Header;
