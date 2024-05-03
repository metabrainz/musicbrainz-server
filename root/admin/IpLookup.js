/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';

import UserList from './components/UserList.js';

component IpLookup(
  ipHash: string,
  pager: PagerT,
  users: $ReadOnlyArray<UnsanitizedEditorT>,
) {
  return (
    <Layout fullWidth title="IP lookup">
      <div id="content">
        <h1>{'IP lookup'}</h1>
        <p>
          {'IP hash: ' + ipHash}
        </p>
        {users.length ? (
          <PaginatedResults pager={pager}>
            <UserList users={users} />
          </PaginatedResults>
        ) : (
          <p>
            {'No results'}
          </p>
        )}
      </div>
    </Layout>
  );
}

export default IpLookup;
