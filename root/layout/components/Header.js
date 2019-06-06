/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import {hydrateClient} from '../../utility/hydrate';

import HeaderLogo from './HeaderLogo';
import TopMenu from './TopMenu';
import BottomMenu from './BottomMenu';

const HeaderContents = ({$c}) => (
  <>
    <a className="navbar-brand my-auto" href="/" title="MusicBrainz">
      <HeaderLogo />
    </a>
    <div className="collapse navbar-collapse flex-md-column">
      <TopMenu $c={$c} />
      <BottomMenu
        $c={$c}
        currentLanguage={$c.stash.current_language}
        serverLanguages={$c.stash.server_languages}
      />
    </div>
  </>
);

const Header = (props) => (
  <div className="bs">
    <nav
      className="navbar navbar-expand-md"
      data-props={JSON.stringify(props)}
      id="header"
    >
      <HeaderContents {...props} />
    </nav>
  </div>
);

export default withCatalystContext(Header);

hydrateClient(HeaderContents, '#header');
