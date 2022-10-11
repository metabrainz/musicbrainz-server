/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';

type Props = {
  +application: ApplicationT,
  +code: string,
};

const OAuth2Oob = ({
  application,
  code,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('OAuth Authorization')}>
    <h1>{l('Success!')}</h1>
    <p>
      {texp.l(
        `You have granted access to {app}. Next, return to {app} and
         copy this token to complete the authorization process:`,
        {app: application.name},
      )}
    </p>
    <p><code>{code}</code></p>
  </Layout>
);

export default OAuth2Oob;
