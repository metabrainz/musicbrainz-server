/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import * as manifest from '../../static/manifest';

import TopMenu from './TopMenu';
import BottomMenu from './BottomMenu';

type Props = {|
  +currentLanguage: string,
  +serverLanguages?: $ReadOnlyArray<ServerLanguageT>,
|};

const Header = ({
  currentLanguage,
  serverLanguages,
}: Props) => (
  <div className="header">
    <a className="logo" href="/" title="MusicBrainz">
      <img className="logo" src={manifest.pathTo('/images/layout/header-logo.svg')} />
    </a>
    <div className="right">
      <TopMenu />
      <BottomMenu
        currentLanguage={currentLanguage}
        serverLanguages={serverLanguages}
      />
    </div>
  </div>
);

export default Header;
