/*
 * @flow strict-local
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import HeaderLogo from './HeaderLogo';
import TopMenu from './TopMenu';
import BottomMenu from './BottomMenu';

const Header = (): React.Element<'div'> => (
  <nav className="navbar navbar-expand-lg navbar-light bg-light">
    <div className="container-fluid">
      <div className="header">
        <a className="logo" href="/" title="MusicBrainz">
          <HeaderLogo />
        </a>
        <div className="right">
          <TopMenu />
          <BottomMenu />
        </div>
      </div>
    </div>
  </nav>
);

export default Header;
