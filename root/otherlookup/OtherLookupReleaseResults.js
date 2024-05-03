/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from '../components/list/ReleaseList.js';
import Layout from '../layout/index.js';

component OtherLookupReleaseResults(results: $ReadOnlyArray<ReleaseT>) {
  return (
    <Layout fullWidth title={l('Search results')}>
      <h1>{l('Search results')}</h1>
      {results.length ? (
        <ReleaseList
          releases={results}
          showLanguages
          showStatus
          showType
        />
      ) : (
        <p>{l('No results found.')}</p>
      )}
    </Layout>
  );
}

export default OtherLookupReleaseResults;
