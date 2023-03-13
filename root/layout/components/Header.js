/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import BottomMenu from './BottomMenu.js';
import HeaderLogo from './HeaderLogo.js';
import TopMenu from './TopMenu.js';

const Header = (): React$Element<'div'> => (
  <div className="header">
    <a className="logo" href="/" title="MusicBrainz">
      <HeaderLogo />
    </a>
    <div className="right">
      <TopMenu />
      <BottomMenu />
    </div>
  </div>
);

export default Header;
