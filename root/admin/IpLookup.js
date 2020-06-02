/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';

import UserList from './components/UserList';

type Props = {
  +$c: CatalystContextT,
  +ipHash: string,
  +users: $ReadOnlyArray<EditorT>,
};

const IpLookup = ({
  $c,
  ipHash,
  users,
}: Props) => (
  <Layout fullWidth title={l('IP lookup')}>
    <div id="content">
      <h1>{l('IP lookup')}</h1>
      <p>
        {l('IP hash:') + ' ' + ipHash}
      </p>
      {users.length ? (
        <UserList $c={$c} users={users} />
      ) : (
        <p>
          {l('No results')}
        </p>
      )}
    </div>
  </Layout>
);

export default withCatalystContext<Props>(IpLookup);
