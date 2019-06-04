/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ACCESS_SCOPE_PERMISSIONS} from '../constants';
import {withCatalystContext} from '../context';
import Layout from '../layout';

type Props = {|
  +$c: CatalystContextT,
  +application: ApplicationT,
  +offline: boolean,
  +permissions: $ReadOnlyArray<number>,
|};

const OAuth2Authorize = ({
  $c,
  application,
  offline,
  permissions,
}: Props) => (
  <Layout fullWidth title={l('OAuth Authorization')}>
    <h1>{l('Authorization')}</h1>

    <p>
      {texp.l('{app} is requesting permission to:', {app: application.name})}
    </p>

    <ul>
      {permissions.map(perm => (
        <li key={perm}>{ACCESS_SCOPE_PERMISSIONS[perm]()}</li>
      ))}
      {application.is_server && offline ? (
        <li>
          {l(`Perform the above operations when I'm not using the
              application`)}
        </li>
      ) : null}
    </ul>

    <form action={$c.req.uri} method="post" name="confirm">
      <span className="buttons">
        <button className="negative" name="confirm.cancel" type="submit" value="1">
          {l('No thanks')}
        </button>
        <button name="confirm.submit" type="submit" value="1">
          {l('Allow access')}
        </button>
      </span>
    </form>
  </Layout>
);

export default withCatalystContext(OAuth2Authorize);
