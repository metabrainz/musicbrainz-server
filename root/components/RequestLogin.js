/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import returnUri from '../utility/returnUri';

type Props = {+$c: CatalystContextT, text?: string};

const RequestLogin = ({$c, text}: Props): React.Element<'a'> => (
  <a className="nav-link" href={returnUri($c, '/login')}>
    {nonEmpty(text) ? text : l('Log in')}
  </a>
);

export default RequestLogin;
