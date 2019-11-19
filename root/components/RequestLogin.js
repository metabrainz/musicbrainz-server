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

type Props = {
  +$c: CatalystContextT,
  +className?: string,
  +text: string,
};

const RequestLogin = ({$c, className = null, text}: Props) => (
  <a className={className} href={returnUri($c, '/login')}>
    {text || l('Log in')}
  </a>
);

export default RequestLogin;
