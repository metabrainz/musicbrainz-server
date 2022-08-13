/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import returnUri from '../utility/returnUri.js';

type Props = {
  +text?: string,
};

const RequestLogin = ({text}: Props): React.Element<'a'> => {
  const $c = React.useContext(CatalystContext);
  return (
    <a href={returnUri($c, '/login')}>
      {nonEmpty(text) ? text : l('Log in')}
    </a>
  );
};

export default RequestLogin;
