/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../../static/manifest.mjs';

import BottomMenu from './BottomMenu.js';
import HeaderLogo from './HeaderLogo.js';
import TopMenu from './TopMenu.js';

component Header() {
  return (
    <div className="header">
      <a className="logo" href="/" title="MusicBrainz">
        <HeaderLogo />
      </a>
      <div className="right">
        <TopMenu />
        <BottomMenu />
      </div>
      {manifest('common/MB/Control/Menu', {async: 'async'})}
    </div>
  );
}

export default Header;
